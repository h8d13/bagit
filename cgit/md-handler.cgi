#!/usr/bin/lua5.3
-- Render markdown files
local md = dofile("/srv/gid/cgit/markdown.lua")

-- Validate input: only allow safe characters (alphanumeric, dots, dashes, underscores, slashes)
local function is_safe(str)
    return str and str:match("^[%w%.%-_/]+$") ~= nil
end

local function url_decode(str)
    return str:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
end

local query = os.getenv("QUERY_STRING") or ""
local repo = query:match("repo=([^&]+)")
local path = query:match("path=([^&]+)")
local ref = query:match("ref=([^&]+)") or "HEAD"

if not repo or not path then
    io.write("Content-Type: text/plain\r\n\r\n")
    io.write("Missing repo or path")
    os.exit(0)
end

-- URL decode
repo = url_decode(repo)
path = url_decode(path)
ref = url_decode(ref)

-- Validate inputs to prevent command injection
if not is_safe(repo) or not is_safe(path) or not is_safe(ref) then
    io.write("Content-Type: text/plain\r\n\r\n")
    io.write("Invalid characters in request")
    os.exit(0)
end

-- Prevent path traversal
if repo:match("%.%.") or path:match("%.%.") then
    io.write("Content-Type: text/plain\r\n\r\n")
    io.write("Path traversal not allowed")
    os.exit(0)
end

-- Get file from git
local git_cmd = string.format("git -C '/data/%s' show '%s:%s' 2>&1", repo, ref, path)
local handle = io.popen(git_cmd)
local content = handle:read("*a")
handle:close()

if content == "" or content:match("^fatal:") then
    io.write("Content-Type: text/plain\r\n\r\n")
    io.write("File not found")
    os.exit(0)
end

io.write("Content-Type: text/html; charset=utf-8\r\n\r\n")
io.write([[<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>]] .. path .. [[</title>
<link rel="stylesheet" href="/cgit-dark.css">
<style>
body { font-family: sans-serif; max-width: 900px; margin: 40px auto; padding: 0 20px; background: var(--bg-color, #fff); color: var(--text-color, #000); }
a { color: var(--link-color, #00c); }
</style>
</head>
<body>
<div class="markdown-body">
]])
io.write(md.markdown(content))
io.write([[
</div>
</body>
</html>
]])
