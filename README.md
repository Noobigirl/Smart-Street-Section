# Smart-Street-Section

CPE project.

---

## 🔀 Git Workflow & Branch Strategy

We use a modified **Git Flow** strategy with `dev` as our default branch and `main` reserved for stable releases.

### Branch Structure
* `main`: Production-ready, stable releases/submissions only.
* `dev`: Primary integration branch (default branch for all work).
* `feature/<feature-name>`: Temporary branches for individual tasks or features.

---

### Step-by-Step Feature Workflow

1. **Start from `dev`:**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name

2. ** Develop & Commit**
Make small, atomic commits with descriptive messages.
```bash
git add .
git commit -m "feat: add user login form validation"
```

3. Keep updated with `dev`:
Before opening a PR, sync your branch with the latest changes from dev

```bash
git fetch origin
git merge origin/dev
```

4. Review & Merge:
- Move your GitHub Project board item to In review.
- Request at least one teammate review.
- Once approved, merge the PR into dev and delete your feature branch.

  ---

##📋 Team Project Management Setup
Use GitHub native tools with the following configuration:

1) Project Board
Project title: `Team Weekly Goals`

View type: `Board`

Columns: `Todo`, `In Progress`, `In review`, `Done`

2) Milestone
Milestone name: Sprint 1: [start date] - [end date]

Due date: [end date]

3) Initial Goal Tracking Issues
Create one issue per deliverable and assign:

Milestone: Sprint 1

Labels: documentation, feature, or design

Assignee(s): Responsible owner(s)

Project: Team Weekly Goals

Issue Body Template:
## Goal
[Describe the deliverable]

## Definition of done
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Notes
- Dependencies:
- Links:
Suggested Initial Deliverables:
Project documentation baseline (documentation)

Smart street core feature implementation (feature)

UI/UX design and flow definition (design)

#📂 File Management
Keep project documentation and other non-code Markdown assets in docs/.

Keep long-form shared notes in the repository Wiki.

Track large binary assets with Git LFS.

#🔄 Team Workflow for Board Status Updates
Move issue card to Todo when created.

Move to In Progress when implementation starts.

Move to In review when opening a PR.

Move to Done after PR merge and acceptance.

Update issue checklist items as work progresses.


<ElicitationsGroup message="Would you like to add any automation templates to your repository next?">
  <Elicitation label="Create a GitHub Pull Request template file" query="Create the raw file content for a GitHub Pull Request template at .github/PULL_REQUEST_TEMPLATE.md for our repository."/>
  <Elicitation label="Create a standard .gitignore file for our project" query="Provide a standard .gitignore file based on common languages and IDEs for our project."/>
  <Elicitation label="Add an Issue Template file for GitHub" query="Create the markdown issue template file content to put inside .github/ISSUE_TEMPLATE/goal_issue.md."/>
</ElicitationsGroup>
