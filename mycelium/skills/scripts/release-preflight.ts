#!/usr/bin/env bun
// Answers one question about the repo in the current directory: is it in a
// state where cutting a release would be honest?
//
// It changes nothing. Everything here is a read, because the failure it exists
// to prevent is a tag pointing at a tree nobody verified -- and a checker that
// can itself alter the tree is one more thing to distrust at the moment you
// most need to trust it.
//
// The version-drift check is the reason this exists at all. muse's tags reached
// v0.6.3 while package.json sat at 0.6.0 for three releases, because three tags
// were cut by hand instead of through the repo's own release script. Nothing
// consuming muse could notice: consumers pin the tag, so the field is read by
// people only. This reads it.

import { $ } from "bun";
import { existsSync, readFileSync } from "node:fs";

// A check is either blocking or advisory, and the split matters. Blocking
// answers "would cutting a tag right now be dishonest" -- a dirty tree, a
// branch that is not main, a version copy that disagrees. Advisory answers
// something true about the past that the next release cannot change, and
// failing on those would leave a repo permanently red for a reason nobody can
// act on, which is how a check trains people to ignore it.
type Check = { name: string; ok: boolean; detail: string; advisory?: boolean };

const checks: Check[] = [];
const add = (name: string, ok: boolean, detail: string, advisory = false) =>
  checks.push({ name, ok, detail, advisory });

// rank turns a semver string into something comparable, so the direction of a
// mismatch can be read.
//
// Direction is the whole point. package.json *behind* the tag is the drift this
// check exists for — muse's tags reached v0.6.3 while the file sat at 0.6.0.
// package.json *ahead* is the opposite thing: a release being cut right now,
// because the bump necessarily lands before the tag does. Blocking on that made
// the check fire during the one operation it is meant to protect, which is how a
// check teaches people to skip it.
const rank = (version: string): number =>
  version.split(".").map(Number).reduce((total, part) => total * 10000 + (part || 0), 0);

const run = async (cmd: string[]): Promise<string> => {
  try {
    return (await $`${cmd}`.quiet()).stdout.toString().trim();
  } catch {
    return "";
  }
};

// An unborn HEAD is a real repository with nothing in it, and saying "not a
// git repository" about one sends the reader looking for the wrong problem.
const hasCommits = (await run(["git", "rev-parse", "--verify", "HEAD"])) !== "";
if (!hasCommits) {
  console.log(" STOP  repository has commits            no commits yet — nothing to release");
  process.exit(1);
}

// The default branch is asked for rather than assumed. GoSvelteBoilerplate's
// is master, and refusing it for that would be this script having an opinion
// about naming while claiming to report readiness.
const fallback = (await run(["git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD"])).replace(/^origin\//, "");
const main = fallback || "main";
const branch = await run(["git", "rev-parse", "--abbrev-ref", "HEAD"]);
add(`on ${main}`, branch === main, branch === main ? `on '${branch}'` : `on '${branch}', default is '${main}'`);

const dirty = await run(["git", "status", "--porcelain"]);
add("working tree clean", dirty === "", dirty ? `${dirty.split("\n").length} file(s) uncommitted` : "clean");

// The one command here that is not a pure read: it updates remote-tracking
// refs, and it needs the network. Nothing else touches the repository, and
// this touches nothing a person is working on -- no index, no worktree, no
// local branch -- but "read-only" would be a claim this line makes false.
await run(["git", "fetch", "--quiet", "origin"]);
const head = await run(["git", "rev-parse", "HEAD"]);
const upstream = await run(["git", "rev-parse", "@{u}"]);
add("in step with origin", head !== "" && head === upstream,
  upstream === "" ? "no upstream branch" : head === upstream ? "same commit" : "HEAD and upstream disagree — pull or push first");

// --exclude '*/*' drops a nested Go module's own tag namespace, which is not a
// cosmetic distinction. A repo publishing submodules carries two tag series at
// once: nacelle has v0.2.2 for the core and tui/v0.2.2 for the client, and
// plain `describe` answers with whichever is newest by reachability, which was
// tui/v0.2.2. Every check below then measures the wrong series, and it does so
// most wrongly during a release, which is the moment the two are deliberately
// out of step and the only moment this script runs.
// Verified 2026-08-23 across the suite: it corrects nacelle and changes nothing
// in tronc, muse, porte or Journal, because a repo with no slashed tags has
// nothing to exclude.
const tag = await run(["git", "describe", "--tags", "--abbrev=0", "--exclude", "*/*"]);
// Advisory, not blocking: a repo cutting its first release has no previous
// tag by definition, and stopping it for that would refuse the one release
// that fixes the condition.
add("has a previous tag", tag !== "", tag || "never tagged — this would be the first release", true);

// The muse check. A version literal anywhere is a copy of the tag, and a copy
// that disagrees is the one that has been forgotten.
if (existsSync("package.json")) {
  try {
    const declared = JSON.parse(readFileSync("package.json", "utf8")).version;
    const expected = tag.replace(/^v/, "");
    const ahead = declared !== undefined && expected !== "" && rank(declared) > rank(expected);
    add("package.json matches the newest tag", declared === expected || tag === "" || ahead,
      declared === undefined
        ? "no version field"
        : ahead
          ? `package.json ${declared} is ahead of ${tag} — a release in progress, tag it`
          : `package.json ${declared}, newest tag ${tag || "(none)"}`);
  } catch {
    add("package.json matches the newest tag", false, "package.json could not be parsed");
  }
}

// REMOVED 2026-08-24: "newest tag was cut by a script", which tested the tag's
// commit subject against /^chore\(release\)/.
//
// It was a real signature once. muse's three drifted tags all pointed at
// ordinary commits because they skipped scripts/release.sh. Then the suite
// deleted that script on purpose -- an automation living in one repo out of
// twenty-eight is one nobody reaches for -- and no repo has produced a
// chore(release) commit since. The check went on firing in every repo, on
// every run, for a convention that no longer exists and that nobody could
// satisfy if they tried.
//
// An advisory that can never be green is worse than no advisory: it is how a
// checker teaches its reader to skip the notes, which is where the checks that
// still mean something live. Confirmed firing on all five repos released this
// session (facile, antenne-cli, capsule-cli, courrier-cli, journal-cli).
//
// The drift it was a proxy for is caught directly by the version-copy check
// above, which reads package.json against the newest tag rather than guessing
// from a commit subject.

// Only meaningful when there is something unreleased to describe. A repo whose
// newest tag is its HEAD has nothing to write down, and demanding an
// [Unreleased] heading from it fails the healthiest state a repo can be in --
// which is what this check did to porte, tronc, caisse, Mycelium and Boutique on
// its first outing across the suite.
// Counting can fail -- a tag on another branch, a shallow clone, git itself
// missing -- and run() reports every failure as the empty string. Number("")
// is 0, which would have made "the count failed" indistinguishable from
// "nothing is unreleased" and skipped the check entirely. A checker that
// fails open is worse than no checker, because it is trusted. Unknown is
// therefore treated as "there might be something", and says so.
// A tagged repo with no changelog at all passes every check below, because
// each one is skipped for a file that does not exist. That is how muse sat on
// four undocumented commits and reported ready: it is the suite's only
// released repo without a CHANGELOG.md. Advisory rather than blocking — the
// absence is worth naming, and it is not a reason to refuse a release.
if (!existsSync("CHANGELOG.md") && tag !== "") {
  add("has a CHANGELOG", false, `released (${tag}) with nothing recording what changed between tags`, true);
}

const counted = tag === "" ? "" : await run(["git", "rev-list", "--count", `${tag}..HEAD`]);
const unreleased = tag === "" ? 1 : counted === "" ? NaN : Number(counted);
const maybeUnreleased = Number.isNaN(unreleased) || unreleased > 0;

if (existsSync("CHANGELOG.md") && maybeUnreleased) {
  const changelog = readFileSync("CHANGELOG.md", "utf8");
  const has = /##\s*\[Unreleased\]/i.test(changelog);
  const since = tag === ""
    ? "never released, so everything is unreleased"
    : Number.isNaN(unreleased)
      ? `could not count commits since ${tag}`
      : `${unreleased} commit(s) since ${tag}`;
  add("CHANGELOG covers the unreleased work", has, has ? since : `${since}, no [Unreleased] section`);
}

for (const c of checks) {
  const mark = c.ok ? "  ok  " : c.advisory ? " note " : " STOP ";
  console.log(`${mark} ${c.name.padEnd(34)} ${c.detail}`);
}

const blocking = checks.filter((c) => !c.ok && !c.advisory);
const notes = checks.filter((c) => !c.ok && c.advisory);
console.log(blocking.length === 0
  ? `\nready to release${notes.length ? ` (${notes.length} note${notes.length > 1 ? "s" : ""} above)` : ""}`
  : `\nnot ready: ${blocking.length} of ${checks.length} must be fixed first`);
process.exit(blocking.length === 0 ? 0 : 1);
