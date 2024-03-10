" dbextprofiles.vim

let g:dbext_default_profile_ProfileA = 'type=DBI:user=username:passwd=xxxx:driver=mysql:conn_parms=database=DBNAME;host=localhost' 
let g:dbext_default_profile_ProfileB_nonDBI='type=MYSQL:user=username:passwd=xxxx:dbname=DBNAME:host=examplehost12345.com'


let g:dbext_default_profile = 'ProfileA'
let g:dbext_default_buffer_lines = 20
let g:dbext_default_DBI_max_rows = 1000 " 0 = unlimited, default = 300
" let g:dbext_default_DBI_column_delimiter = "\t" " t= tab, | = normal, ...
let g:dbext_default_DBI_column_delimiter = " | "
"let g:dbext_default_prompt_for_parameters=0 " Turn off parameter prompt
"let g:dbext_suppress_version_warning=1
"let g:dbext_rows_affected = 1
"let g:dbext_default_use_sep_result_buffer = 1 " Each buffer has its own results window
let g:dbext_default_display_cmd_line = 0 " Do NOT display cmd as well
let g:dbext_default_history_file = '$HOME/.dbext_sql_history.txt'

" Example modelines to go at beginning of SQL files to define connection to be
" used:
" // dbext:profile=ProfileA

" To get DBI working:
" 1) install VIM with perl support (check vim, :version)
" sudo apt-get install vim-gtk
" 2) install libdbi driver (e.g. for mysql)
" sudo apt-get install libdbi-perl
" sudo apt-get install libdbd-mysql-perl
"
