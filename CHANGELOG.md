## 0.6.1 (jasonwebster/forge)

- Ensure entire project is built once when starting `watch`
- Fix issue with empty subdirectories in includes
- Always ensure build folder exists when trying to build

## 0.6.0 (jasonwebster/forge)

**Important:** If you have `compiled_assets` declarations in your `config.rb`
file, remove them. They are no longer supported and no longer necessary, as the
new sprockets setup always copies all non-partial files.

- Use Sprockets for all assets, including images.
- New watch process. No longer uses guard. This uses listen directly, and
  is getting smarter about what to recompile/build.
- New project generator and template system

## 0.5.0 (jasonwebster/forge)

- Initial fork
