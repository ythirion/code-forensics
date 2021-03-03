for i in "$@"
do
case $i in
    -p=*|--projectName=*)
    projectName="${i#*=}"
    ;;
    -r=*|--repositoryPath=*)
    repositoryPath="${i#*=}"
    ;;
esac
done


dateFrom=$(git --git-dir $repositoryPath/.git log --reverse --pretty=format:"%ad" --date=short| sed -n 1p)
dateTo=$(date +%Y-%m-%d)
targetFile=/
green='\033[0;32m'
noColor='\033[0m'

print() {
    echo "${green}$1${noColor}"
}

print "CLEAN FOLDERS"
rm -rf output
rm -rf tmp

print "INJECT VARIABLES"
sed -i '' "s|project|$projectName|g" package.json
sed -i '' "s|repositoryPath|$repositoryPath|g" gulpfile.js


print "INSTALL DEPENDENCIES"
npm install

print "CODE ANALYSIS"
print "Run Hotspot analysis"
gulp hotspot-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo
print "RUN Complexity trend analysis"
gulp sloc-trend-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --timeSplit=eom
print "RUN Coupling analysis"
gulp sum-of-coupling-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --timeSplit=eom
print "RUN System evolution analysis"
gulp system-evolution-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --timeSplit=eom

print "SOCIAL ANALYSIS"
print "RUN Commit message analysis"
gulp commit-message-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --minWordCount=1
print "RUN Developer coupling analysis"
gulp developer-coupling-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo
print "RUN Developer effort analysis"
gulp developer-effort-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo
print "RUN Knowledge Map analysis"
gulp knowledge-map-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo
