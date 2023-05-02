# str2Hex # Convert a string to hex charcters.

function str2Hex ()
{
    ## Individual charcter arrays
    # Letters with diacritical marks
    # Element [0] will replace [1+]
    CHAR00=( 0 o ɛ ó ò ŏ ô ố ồ ỗ ổ ǒ ö ő õ ø ǿ ǫ ō ỏ ơ ớ ờ ỡ ở ợ ọ ộ œ ɔ ɵ ʘ ) #o#
    CHAR01=( 1 í ì ĭ î ǐ ï ĩ į ī ỉ ị ĳ ı ɨ ɩ ɟ l ĺ ľ ļ ł ḷ ḹ ḽ ḻ ŀ ǉ ʪ ʫ ƚ ɫ ɬ ɭ ɮ ƛ ) #i#l#
    CHAR02=( 2 z ź ž ż ẓ ẕ ƶ ʐ ʑ ) #z#
    CHAR03=( 3 )
    CHAR04=( 4 )
    CHAR05=( 5 s ś ŝ š ṡ ş ṣ ș ſ ß ʂ ʃ ʅ ʆ ) #s#
    CHAR06=( 6 )
    CHAR07=( 7 t ð ť ẗ ţ ṭ ț ṱ ṯ ʨ ʦ ʧ ŧ ʈ ʇ þ ) #t#
    CHAR08=( 8 )
    CHAR09=( 9 g ǵ ğ ĝ ǧ ġ ģ ḡ ɡ ɠ ɣ ) #g#
    CHAR10=( a á à ă ắ ằ ẵ ẳ â ấ ầ ẫ ẩ ǎ å ǻ ä ã ą ā ả ạ ặ ậ æ ǽ ɐ ɑ ɒ ) #a#
    CHAR11=( b ḅ ɓ ß ) #b#
    CHAR12=( c ć ĉ č ċ ç ɕ ) #c#
    CHAR13=( d ď đ ḍ ḓ ḏ ð ǳ ʣ ǆ ʥ ʤ ɖ ɗ ) #d#
    CHAR14=( e é è ĕ ê ế ề ễ ể ě ë ẽ ė ę ē ẻ ẹ ệ ə ɘ ɚ ɜ ɝ ɞ ʚ ʒ ǯ ʓ ) #e#
    CHAR15=( f ﬁ ﬂ ʩ ƒ ɟ ʄ ſ ʃ ʅ ʆ ) #f#

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
