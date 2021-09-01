while read url; do
    name=`echo $url | rev | cut -f1 -d'/' | rev`
    name=${name%.tar.gz}
    # echo $name
    cp -v /vscratch1/cwpears/${name}.mtx ~/suitesparse/. || \
    cp -v /vscratch1/cwpears/**/${name}.mtx ~/suitesparse/.
done < suitesparse-reals-regular.txt