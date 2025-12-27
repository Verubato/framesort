# luacheck requires a C environment
choco install visualstudio2022buildtools -y
choco install visualstudio2022-workload-vctools -y
choco install windows-sdk-10-version-2004-all -y

# lua runtime
choco install lua -y

# lua package manager
choco install luarocks -y

# install luacheck
./install-luacheck.ps1 -PersistLuacheckPath User

# refresh the path env variable
$env:Path = ( [System.Environment]::GetEnvironmentVariable("Path","Machine"),
              [System.Environment]::GetEnvironmentVariable("Path","User") ) -match '.' -join ';'
