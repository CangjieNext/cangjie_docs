# Contributing Documents

[查看中文](./CONTRIBUTING_zh.md)

Welcome to contribute to the Cangjie documentation. You can evaluate, modify, provide feedback on existing documents, or contribute original content. We encourage developers to participate in document feedback and contributions in various ways.

## Content Copyright

User-submitted content and images must be original and must not infringe on others' intellectual property rights.

Cangjie reserves the right to modify developer-contributed content according to relevant guidelines.

## License

Creative Commons License version 4.0

## Contribution Methods

### Providing Feedback on Document Issues

High-quality feedback helps us continuously improve the content and quality of the documentation. The more detailed the information you provide, the more helpful it is for us to improve the issues.

1. In the corresponding repository on GitCode, go to the "Issues" tab, click "New issue," describe the issue in the title bar, and add a detailed description of the problem in the editing box.
2. Click the "New issue" button to submit your issue. Please wait patiently for the members of the Cangjie Document team to confirm your problem.

> **How to Provide High-Quality Feedback?**
>
> - Provide the specific location, name of the document, and a clear description of the issue. Specify the missing or incorrect content or the text that needs improvement, and provide screenshots if necessary.
> - Explain the impact of the issue on users.
> - If the issue is with a document example, provide the specific Cangjie version, environment, and error message.
> - Limit the scope of the given issue to a specific content or task. If the issue involves a broad area, break it down into smaller issues. For example, "The documentation needs optimization" is too broad, while "The XX development guide lacks an introduction to the XXX steps" is a specific and actionable issue.
> - Search the existing issue list to see if a related or similar issue has already been recorded.
> - If the new issue is related to another issue or PR, you can reference it using its full URL or the PR number with the \# character.

### Online Changes

For quick changes and fixes to existing documents, suitable for minor content modifications and additions.

Submission Steps:

1. Click the "IDE" button in the upper right corner of the GitCode documentation page to jump to the corresponding project source file page.
2. On the GitCode source file page, complete the changes and fixes at the corresponding content.
3. After completing the modifications, you can click the Markdown preview button in the upper right corner of the page to confirm the modification results.
4. After confirming that everything is correct, fill in the modification comments and supplementary information, and the Signed-off-by email in the submission panel on the left.

    Example: `Signed-off-by: user.name <user.email>` // Ensure it matches the DCO signing email

The Cangjie Document team will review and merge your changes. Thank you for your support and assistance with Cangjie Document.

### Local Changes

Suitable for scenarios requiring extensive modifications or additions.

Submission Steps:

1. Fork the project repository.
2. Clone the project to your local machine and create a branch for document changes.
3. After completing the document changes locally, submit a PR.
4. Wait for gatekeeper verification and review by the Cangjie Document team. Once approved, the changes will be merged.

### Checking Your Changes Before Submitting

`scripts/docs_lint.py` performs offline checks on the Markdown sources, so a broken link or an inconsistent term is caught before review:

```shell
python scripts/docs_lint.py            # whole repository
python scripts/docs_lint.py docs/      # a sub-tree, for example the files you changed
```

The default checks are:

- relative links and images resolve to a file that exists in the repository;
- absolute links into this repository point to an existing path;
- Chinese wording follows the agreed glossary, for example `其它` → `其他`.

Pass `--anchors` to also verify `#fragment` targets against the headings of the target file. That mode is best effort: explicit `{#id}` anchors are supported, but the slug rules of the published site may differ in rare cases, so read the findings instead of applying them blindly.

Code blocks and inline code are ignored by every check, because Cangjie syntax such as `@Foo[1+](2+3)` looks like a Markdown link. The script needs Python 3.8 or later and no third-party package; its own tests run with `python -m unittest discover scripts`. Please report problems with the script in an issue rather than mixing them into a documentation PR.
