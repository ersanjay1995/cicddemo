
FILE=$1/buildspec.yml
if test -f "$FILE"; then
    echo "$FILE applying build spec ."



  aws codebuild start-build --project-name ${APP_ID} --source-version $CODEBUILD_SOURCE_VERSION --buildspec-override $1/buildspec.yml --artifacts-override type=s3,location=$S3_BUCKET,path=$(cut -d/ -f2-4 <<< $CODEBUILD_SOURCE_VERSION)_op |jq -r ".build.id" >$1/bid
       sleep 30; maxTime=45;
       until aws codebuild batch-get-builds --ids $(cat $1/bid) | jq -r ".builds[0].buildStatus" | grep -q "SUCCEEDED"; do sleep 1;if [[ $((maxTime--)) -lt 0 ]]; then echo Timedout; exit 1; fi;  done;
       #aws codebuild batch-get-builds --ids $(cat $1/bid)
       fyml=$(aws codebuild batch-get-builds --ids $(cat $1/bid) |  jq -r ".builds[0].artifacts.location")/template-export.yml
     #  echo $f3yml
       aws s3 cp s3://${fyml##*:::} $1/template.yml

fi
