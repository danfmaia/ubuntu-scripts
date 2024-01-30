import subprocess


def generate_prompt():
    # Prompt for the desired language
    language = input(
        "Enter the desired language (pt-br/en, default=pt-br): ").lower()
    if language != "en":
        language = "pt-br"

    # Prompt for PR name
    pr_name = "refactor: apply major refactor to the InvoiceComponent widget"
    # pr_name = input("Enter the PR name: ")

    # Prompt for work branch and target branch names
    # work_branch = input("Enter the work branch name: ")
    # target_branch = input("Enter the target branch name: ")
    work_branch = "refactor/invoices-style"
    target_branch = "bugfix/open-invoices-style-2"

    # Generate commit data based on selected branches
    commit_data = generate_commit_data(work_branch, target_branch)

    # Create the file content in text format
    file_content = f"""Given the following data of a PR:

PR Name: {pr_name}

Commit Data:
{generate_commit_data_text(commit_data)}

And this extra instruction: [extra info]

Write the commit message for those
"""

    # Save the file
    file_name = f"{pr_name.lower().replace(' ', '_')}_prompt.txt"
    with open(file_name, "w") as file:
        file.write(file_content)

    print(f"Prompt generated successfully! Saved as {file_name}")


def generate_commit_data(work_branch, target_branch):
    # Execute Git commands to retrieve commit data
    commit_data = []

    commit_hashes = subprocess.check_output(
        f"git rev-list {target_branch}..{work_branch}", shell=True
    ).decode().strip().split("\n")

    print('commit_hashes: ', commit_hashes)

    for commit_line in commit_hashes:
        commit_hash = commit_line.split(" ")[0]
        commit_diff = subprocess.check_output(
            f"git diff {commit_hash}^..{commit_hash}", shell=True
        ).decode().strip()
        commit_message = subprocess.check_output(
            f"git log --format='%B' -n 1 {commit_hash}", shell=True
        ).decode().strip()

        commit_data.append({
            "hash": commit_hash,
            "message": commit_message,
            "diff": commit_diff
        })

    return commit_data


def generate_commit_data_text(commit_data):
    # Generate text representation of commit data
    text = ""

    for i, commit in enumerate(commit_data, start=1):
        text += f"Commit {i}:\n"
        text += f"Hash: {commit['hash']}\n"
        text += f"Message: {commit['message']}\n"
        text += f"Diff:\n{commit['diff']}\n"

    return text


generate_prompt()
