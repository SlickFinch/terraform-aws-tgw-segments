# Changelog

## v1.0.0

- First release. Creates one Transit Gateway route table per segment, accepts spoke attachments, associates each with its segment and propagates it into every segment whose `reaches` list includes it. Accepters have `prevent_destroy`.
