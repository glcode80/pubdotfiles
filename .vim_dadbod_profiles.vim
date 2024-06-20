" Connection profiles for vim-dadbod
" Can set global default + per buffer profiles (to select via '-- DB: xxx' in first 10 lines of buffer

" Set global default connection
let g:db = "mysql://user:password@hostname:port"
" let g:db = "mysql://user:password@hostname:port/dbname"

" Set buffer connections -> can be selected by setting '-- DB: xxx' in first 10 lines of buffer
" Legacy option: also works on '// dbext:profile=xxx'
" Can also be used to set to a specific schema on connection via /dbname
let g:db_buffer = {
      \ 'dbname1': 'mysql://user:password@hostname:port/dbname1',
      \ 'dbname2': 'mysql://user:password@hostname:port/dbname2',
      \ 'fulldbnoport': 'mysql://user:password@hostname',
      \ }
