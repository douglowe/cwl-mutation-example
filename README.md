This is an example workflow, for testing file paths in CWL which include colons (:).

### Setup

These workflows make use of the BioBB libraries, which are installed using `git submodules`. This requires that you clone this repository, rather than downloading a zip archive (as the git hooks are needed for this to work):
```
git clone --recurse-submodules https://github.com/douglowe/cwl-mutation-example.git
```

### Running the Workflows

Use this command:
```
cwltool md_launch_mutate.cwl md_mutate_input_descriptions.yml
```

