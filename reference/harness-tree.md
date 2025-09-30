# Workspace Harness Parent/Child Tree and Deployment

## Harness Types: Base, Leaf, and Primary

### Base Harnesses

Base harnesses are designed to be extended by other harnesses. They provide
shared logic, configuration, and files for their children.

#### PHP Base Harness

- **harness-base-php** (Base)
  - harness-akeneo (Leaf)
  - harness-drupal8 (Leaf)
  - harness-magento1 (Leaf)
  - harness-magento2 (Leaf)
  - harness-spryker (Leaf)
  - harness-symfony (Leaf)
  - harness-wordpress (Leaf)

#### Node Base Harness

- **harness-base-node** (Base)
  - harness-node-spa (Leaf)
  - harness-viper (Leaf)

### Primary Harnesses

Primary harnesses are independent harnesses that are not derived from a base
harness and do not currently serve as a base for others. They are
self-contained and may be used directly in projects.

- **harness-docker** (Primary)
- **harness-go** (Primary)

> Note: If a Primary harness is later extended by others, it should be renamed
> as a Base harness (e.g., harness-base-docker).

## How Inheritance Works

- Shared files and logic live in `src/_base` of the Base harness.
- Each Leaf harness has its own directory in `src/<child>`.
- The build script merges `_base` and child files into `dist/harness-<child>`.
- There is no explicit `extends` in YAML; inheritance is by file copying/merging.

## How Are Harnesses Built and Deployed?

- Run the `build` script in the Base harness repo.
- This creates a full harness for each Leaf in `dist/harness-<child>`.
- Each Leaf harness can be published to its own git repo or as a tarball.
- CI (e.g., Jenkins) can automate build, test, and deploy steps.

## Example Build Script (Excerpt)

```bash
HARNESSES=(akeneo drupal magento1 magento2 symfony wordpress)
for harness in "${HARNESSES[@]}"
do
  build "$harness"
  # ...
done
```

## References

- See the main README for more details on structure and usage.
- [Workspace Documentation](https://github.com/my127/workspace)
- [harness-docker](https://github.com/inviqa/harness-docker)
- [harness-go](https://github.com/inviqa/harness-go)

