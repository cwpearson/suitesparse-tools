#! /bin/bash

set -eou pipefail

match_size_or_get() {
    url=$1
    echo "working on $url"

    # get expected size of url content.
    # first, follow redirects to get effective url
    # then, ask how big the content at the effective URL is
    # remove the carriage return from the header
    urleff=$(curl -sLI -o /dev/null -w %{url_effective} $url)
    esz=$(curl -sI $urleff | grep -i Content-Length: | cut -d' ' -f2)
    esz=`echo -n $esz | tr -d '\r'` # get rid of carriage return

    # check size of file (0 if absent)
    name=`basename $url`
    if [ -f $name ]; then 
        sz=$(wc -c < $name | tr -d '[:space:]\n')
    else
        sz=0
    fi

    # convert to number
    sz=$(( $sz ))
    esz=$(( $esz ))

    # redownload if local file does not match expected size
    if [ $sz != $esz ]; then
        echo $name "was" $sz "(expected $esz)"
        curl -sSLO $url
    else
        echo $name "was expected size" $esz
    fi

    set -x

    # get expected extracted size. assuming a single file in the tar
    # head will read the first line and quit, causing exit 141 when the tar
    # continues to try to write into it
    esz=$(tar tzvf $name | head -n 1 | tr -s ' ' |  cut -d' ' -f3 || if [[ $? -eq 141 ]]; then true; else exit $?; fi )
    extname=$(basename -s .tar.gz $name)
    extname=$extname.mtx

    # get size of extracted file, if present
    if [ -f $extname ]; then
        sz=$(wc -c < $extname | tr -d '[:space:]\n')
    else
        sz=0
    fi

    # convert to number
    sz=$(( $sz ))
    esz=$(( $esz ))

    # re-extract file if size is not expected
    if [ $sz != $esz ]; then
        echo $extname "was" $sz "(expected $esz)"
        tar --strip-components 1 -xvf  $name
    else
        echo $extname "was expected size" $esz
    fi

}

while read url; do
    match_size_or_get $url;
    sleep 5;
done < suitesparse-reals-regular.txt