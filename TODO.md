## Custom Output Paths

* `project_root` - build all paths off this
  - fontcustom.yml? `project_root` is pwd
  - config/fontcustom.yml? `project_root` is ../.
  - can be customized via fontcustom.yml
  - defaults to pwd

* `output` can be a string or hash. If a hash, each key/value is a pattern and output dir for matching files.
  - If hash, a `default` key must be present.

* `input` could also be a hash. Requires a :vectors key. :templates is optional

* Ensure that cleanup of old files is:
  - using `project_root`
  - using the output 

