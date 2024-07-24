if [ -z "$1" ]; then
    echo "error: no argument"
    echo "options available:"
    echo "love, html5"
    exit 1
fi

case $1 in

    love | lua)
        ./cli.sh build ./broco/game.lua --core love --run
    ;;

    html | html5)
        ./cli.sh build ./broco/game.lua --core html5
    ;;

    ginga)
        # ./cli.sh build ./broco/game.lua --core love --run
    ;;

    *)
        echo "error: invalid argument"
    ;;

esac

# ./cli.sh build ./broco/game.lua --core love --run