local cmd = function(c) assert(require('os').execute(c), c) end

cmd('mkdir -p doxygen')
cmd('doxygen -w html doxygen/header.html doxygen/delete_me.html doxygen/delete_me.css')

local text_clipboard = '<!--END COPY_CLIPBOARD-->\n'
local copy_clipboard_pattern = '<%!%-%-END COPY_CLIPBOARD%-%->'
local plugin_toggle_darkmode = '<script type="text/javascript" src="$relpath^doxygen-awesome-darkmode-toggle.js"></script>\n'
    ..'<script type="text/javascript">DoxygenAwesomeDarkModeToggle.init()</script>'
local plugin_paragraph_link = '<script type="text/javascript" src="$relpath^doxygen-awesome-paragraph-link.js"></script>\n'
    ..'<script type="text/javascript">DoxygenAwesomeParagraphLink.init()</script>'

local header_file = io.open('doxygen/header.html', 'r')
local header_content = header_file:read('*a')

header_file:close()

header_file = io.open('doxygen/header.html', 'w')
header_content = header_content:gsub(copy_clipboard_pattern, text_clipboard..plugin_paragraph_link)
header_content = header_content:gsub(copy_clipboard_pattern, text_clipboard..plugin_toggle_darkmode)

header_file:write(header_content)
header_file:close()
