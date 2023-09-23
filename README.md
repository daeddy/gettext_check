# GettextCheck
[![hex.pm badge](https://img.shields.io/badge/Package%20on%20hex.pm-informational)](https://hex.pm/packages/gettext_check)
[![Documentation badge](https://img.shields.io/badge/Documentation-ff69b4)][docs-gettext_check]
![CI badge](https://github.com/daeddy/gettext_check/workflows/Test/badge.svg)

GettextCheck is a tool to check for missing translations in
[GNU gettext](https://www.gnu.org/software/gettext/) `po` and `pot` files.

Designed to work with the elixir [gettext](https://github.com/elixir-gettext) package,
your files must be saved in the [gettext directory structure](https://hexdocs.pm/gettext/Gettext.html#module-messages) 
  e.g. `priv/gettext/LOCALE/LC_MESSAGES/DOMAIN.po`.

Read the [documentation for the `GettextCheck` module](https://hexdocs.pm/gettext_check/GettextCheck.html) for more information on backend functions.

## Usage

  ```bash
  mix gettext_check [OPTIONS]
  ```

  #### Options

  * `--locale` or `-l` - the locale to check
    * Will be used with priv to find the locale files (e.g. `{priv}/{locale}/LC_MESSAGES`)
    * This can also be set under the config
    * Required either here or under the config
  * `--priv` or `-p` - the path to the priv directory
    * Defaults to `priv/gettext`
    * This can also be set under the config

## Configuration
You need to specify the locale but the priv directory is optional
(default to `priv/gettext`).

`GettextCheck` can be configured in two ways:

#### 1. Command line options

```bash
  mix gettext_check --locale ja --priv priv/gettext
```

#### 2. Mix config

```elixir
  config :gettext_check,
    locale: "ja",
    priv: "priv/gettext"
```

## Contributing

1. [Fork it!](http://github.com/daeddy/gettext_check/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[docs-gettext_check]: http://hexdocs.pm/gettext_check
