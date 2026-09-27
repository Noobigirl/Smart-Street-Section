# Smart-Street-Section

CPE project.

## Team project management setup

Use GitHub native tools with the following configuration:

### 1) Project board
- **Project title:** `Team Weekly Goals`
- **View type:** Board
- **Columns:** `Todo`, `In Progress`, `In review`, `Done`

### 2) Milestone
- **Milestone name:** `Sprint 1: [start date] - [end date]`
- **Due date:** `[end date]`

### 3) Initial goal tracking issues
Create one issue per deliverable and assign:
- milestone: `Sprint 1`
- labels: `documentation`, `feature`, or `design`
- assignee(s): responsible owner(s)
- project: `Team Weekly Goals`

Issue body template:

```md
## Goal
[Describe the deliverable]

## Definition of done
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Notes
- Dependencies:
- Links:
```

Suggested initial deliverables:
- Project documentation baseline (`documentation`)
- Smart street core feature implementation (`feature`)
- UI/UX design and flow definition (`design`)

## File management
- Keep project documentation and other non-code Markdown assets in `docs/`.
- Keep long-form shared notes in the repository Wiki.
- Track large binary assets with Git LFS.

## Team workflow for board status updates
1. Move issue card to **Todo** when created.
2. Move to **In Progress** when implementation starts.
3. Move to **In review** when opening a PR.
4. Move to **Done** after PR merge and acceptance.
5. Update issue checklist items as work progresses.
