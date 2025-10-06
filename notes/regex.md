
## Sample regex

Remove lines that do not start with `https:` or `password` in the buffer

```vim
:%s/^\(\(https:\|password\)\@!\).*/
```
