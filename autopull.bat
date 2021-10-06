@ECHO OFF
set pull_count = 0

:pull
    cls
    git pull --tags origin main

    set /a pull_count = %pull_count%+1
   
    echo [91m_____________________________________________________________________________[0m
    echo.
    echo [92mgit pull[0m request maked, waiting [93m1 hour[0m for the next
    echo This is the [94m%pull_count%[0m time that the git pull request was maked

    timeout 3600 /nobreak>nul

    :: Restart the pull request
    GOTO pull