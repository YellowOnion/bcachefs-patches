#/bin/env bash

out=$PWD
rm v5.11/bcachefs*.patch
rm v5.10/bcachefs*.patch
rm v5.9/bcachefs*.patch

cd bcachefs
git fetch --shallow-since="2020-07-21"

for version in "v5.11 origin/master 2020-12-20" "v5.10 origin/bcachefs-v5.10 2020-12-18" "v5.9 origin/bcachefs-v5.9 2020-07-22"; do
    set - $version; tag=$1; branch=$2; oldest=$3;
    echo "starting patches for $tag $branch till date $oldest"
    COMMIT=$(git log $tag..$branch --format='%ad %H %h' --date=short -n 1)
    set olddate="no"
    set - $COMMIT; date=$1; id=$2; short=$3;
    while [ "$olddate" != "$date" ]; do
        echo "creating patch for $tag $date"
        git diff $tag $id > "$out"/$tag/bcachefs-$tag-$date-$short.patch
        COMMIT=$(git log $tag..$branch --since="$oldest 00:00:00" --format='%ad %H %h' --before="$date 00:00:00" --date=short -n 1)
        olddate=$date
        set - $COMMIT; date=$1; id=$2; short=$3;
    done
done

[ $olddate != "no" ] && exit 1
