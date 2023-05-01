# str2Hex # Convert a string to hex charcters.

function str2Hex ()
{
    ## Individual charcter arrays.
    # Element [0] will replace [1+]
    CHAR00=( 0 o )
    CHAR01=( 1 i l )
    CHAR02=( 2 z )
    CHAR03=( 3 )
    CHAR04=( 4 )
    CHAR05=( 5 s )
    CHAR06=( 6 )
    CHAR07=( 7 t )
    CHAR08=( 8 )
    CHAR09=( 9 g )
    CHAR10=( a )
    CHAR11=( b )
    CHAR12=( c )
    CHAR13=( d )
    CHAR14=( e )
    CHAR15=( f )

    ## Array of the charcter arrays.
    CHAR_ARRAY=(
        CHAR00[@]
        CHAR01[@]
        CHAR02[@]
        CHAR03[@]
        CHAR04[@]
        CHAR05[@]
        CHAR06[@]
        CHAR07[@]
        CHAR08[@]
        CHAR09[@]
        CHAR10[@]
        CHAR11[@]
        CHAR12[@]
        CHAR13[@]
        CHAR14[@]
        CHAR15[@]
    )

    for letter in $(fold -w1 <<<"${1:-coffee}"); do
        for ((i=0; i<${#CHAR_ARRAY[@]}; i++)); do
           for char in ${!CHAR_ARRAY[i]}; do
              [[ "${letter}" == "${char}" ]] && {
                 echo -en "${!CHAR_ARRAY[i]:0:1}"
              }
           done
        done
    done
}
