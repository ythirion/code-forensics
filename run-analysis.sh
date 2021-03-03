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
sed -i '' "s|projectName|$projectName|g" package.json
sed -i '' "s|repositoryPath|$repositoryPath|g" gulpfile.js


print "INSTALL DEPENDENCIES"
npm install

print "CODE ANALYSIS"
print "Run Hotspot analysis (1/8)"
gulp hotspot-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo
print "RUN Complexity trend analysis (2/8)"
gulp sloc-trend-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --timeSplit=eom
print "RUN Coupling analysis (3/8)"
gulp sum-of-coupling-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --timeSplit=eom
print "RUN System evolution analysis (4/8)"
gulp system-evolution-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --timeSplit=eom

print "SOCIAL ANALYSIS"
print "RUN Commit message analysis (5/8)"
gulp commit-message-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo --minWordCount=1
print "RUN Developer coupling analysis (6/8)"
gulp developer-coupling-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo
print "RUN Developer effort analysis (7/8)"
gulp developer-effort-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo
print "RUN Knowledge Map analysis (8/8)"
gulp knowledge-map-analysis --targetFile=$targetFile --dateFrom=$dateFrom --dateTo=$dateTo

print "RUN webserver on http://localhost:3000/"
gulp webserver