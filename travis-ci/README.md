# Travis CI

## Build Lifecycle

1. Install `apt addons`
2. `before_install`
3. `install` install any dependencies required
4. `before_script`
5. `script` run the build script
6. `after_success` or `after_failure`
7. OPTIONAL `before_deploy`
8. OPTIONAL `deploy`
9. OPTIONAL `after_deploy`
10. `after_script`
