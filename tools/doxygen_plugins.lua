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

local icon_clipboard = '<!--END PROJECT_ICON-->\n'
local icon_clipboard_pattern = '<%!%-%-END PROJECT_ICON%-%->'
local plugin_metadata = [[
<meta name="title" content="$projectname Docs"/>
<meta name="summary" content="$projectbrief"/>
<meta name="description" content="$title"/>

<meta property="og:type" content="website"/>
<meta property="og:title" content="$projectname Docs"/>
<meta property="og:site_name" content="$projectbrief"/>
<meta property="og:description" content="$title"/>
<meta property="og:image" content="http://docs.gamely.com.br/icon80x80.png"/>

<meta property="twitter:card" content="summary_large_image"/>
<meta property="twitter:title" content="$projectname Docs"/>
<meta property="twitter:description" content="$title"/>
<meta property="twitter:image" content="http://docs.gamely.com.br/icon80x80.png"/>
]]

header_file:close()

header_file = io.open('doxygen/header.html', 'w')
header_content = header_content:gsub(copy_clipboard_pattern, text_clipboard..plugin_paragraph_link)
header_content = header_content:gsub(copy_clipboard_pattern, text_clipboard..plugin_toggle_darkmode)
header_content = header_content:gsub(icon_clipboard_pattern, icon_clipboard..plugin_metadata)

header_file:write(header_content)
header_file:close()
