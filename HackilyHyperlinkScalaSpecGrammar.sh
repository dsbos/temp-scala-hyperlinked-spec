#!/bin/sh
# Hackily adds hypertext links from references to definitions of
# non-terminals in the grammar BNF in the Scala language specification.
#
# (This is NOT a draft of a proposed implementation for adding such
# links; just a temporary implementation to get rough results for
# demonstrating grammar linking.)

SOURCE_URL=http://www.scala-lang.org/files/archive/spec/2.12/
CUT_DIRS=4


WORK_ROOT=target
DOWNLOAD_ROOT=${WORK_ROOT}/download
OUTPUT_ROOT=${WORK_ROOT}/output

mkdir -p ${WORK_ROOT}

DOWNLOAD=true
#DOWNLOAD=false
if $DOWNLOAD ; then
    mkdir -p ${DOWNLOAD_ROOT}
    (
	cd ${DOWNLOAD_ROOT} &&
	    wget \
		--wait=1  --timestamping `# download "gently" ` \
		--recursive --no-parent  `# download only spec. resources ` \
		--convert-links \
		--no-host-directories --cut-dirs="${CUT_DIRS}" \
		"${SOURCE_URL}"
    )
fi

pwd

# Exceptions:
# 10-xml-expressions-and-patterns.html:BaseChar, Char, Comment, CombiningChar, Ideographic, NameChar, S, Reference
# 10-xml-expressions-and-patterns.html:              ::=  $\textit{“as in W3C XML”}$

# 13-syntax-summary.html:# floatingPointLiteral
# 13-syntax-summary.html:#                 ::=  digit {digit} ‘.’ digit {digit} [exponentPart] [floatType]

#
(
    cd ${DOWNLOAD_ROOT}
    grep '::=' [0-9][0-9]-*.html  \
	| sed -e 's/<div class="highlight"><pre><code class="language-ebnf" data-lang="ebnf">//'  \
	| grep -E -e ': *[^ ]+ *::=' 	  \
	| sed -e 's/ *::=.*//'  \
	| sed -E -e 's/(.*): *(.*)/\2 \1/'  \
	| grep -v "13-syntax-summary.html"  \
	| sort
) > ${WORK_ROOT}/NameToFileMap.tmp
rm -fr  ${OUTPUT_ROOT}
mkdir  ${OUTPUT_ROOT}
cp  -r  ${DOWNLOAD_ROOT}/.  ${OUTPUT_ROOT}
sed -E -i .bak \
    `# Mark identifier-like runs:  ` \
    -e '/data-lang="ebnf"/,/<\/code>/   s|([A-Za-z0-9]+)|<t>\1</t>|g'  \
    `# Unmark HTML - start:  ` \
    -e 's,<<t>div</t> <t>class</t>="<t>highlight</t>"><<t>pre</t>><<t>code</t> <t>class</t>="<t>language</t>-<t>ebnf</t>" <t>data</t>-<t>lang</t>="<t>ebnf</t>">,<div class="highlight"><pre><code class="language-ebnf" data-lang="ebnf">,' \
    `# Unmark HTML - end:  ` \
    -e 's,</<t>code</t>></<t>pre</t>></<t>div</t>>,</code></pre></div>,' \
    `# Unmark post-// runs:` \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(//.*)<t>([A-Za-z0-9]+)</t>|\1\2|g' \
    `# Unmark literals: ` \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(‘[^‘’]*)<t>([^‘’]+)</t>([^‘’]*’)|\1\2\3|g' \
    `# Unmark $\textit itself: ` \
    -e '/data-lang="ebnf"/,/<\/code>/ s|\\<t>textit</t>|\\textit|g' \
    `# Unmark $\textit{ ... } runs: ` \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(textit[{][^{})]*)<t>([^<>{}]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(textit[{][^{})]*)<t>([^<>{}]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(textit[{][^{})]*)<t>([^<>{}]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(textit[{][^{})]*)<t>([^<>{}]+)</t>|\1\2|g' \
    -e '/data-lang="ebnf"/,/<\/code>/ s|(textit[{][^{})]*)<t>([^<>{}]+)</t>|\1\2|g' \
    \
    `# Label definitions . runs before "::=": ` \
    -e '/data-lang="ebnf"/,/<\/code>/ s|<t>([A-Za-z0-9]+)</t>(.*::=)|<pd>\1</pd>\2|'  \
    `# Label definitions . exceptions:    BaseChar, floatingPointLiteral` \
    -e '/data-lang="ebnf"/,/<\/code>/ s|^<t>(floatingPointLiteral)</t>$|<pd>\1</pd>|'  \
    -e '/DISABLEdata-lang="ebnf"/,/<\/code>/ s|data-lang="ebnf"><t>BaseChar</t>|YYYdata-lang="ebnf"><pr>BaseChar</pr>ZZZ|'  \
    `# Label references . remaining runs (all): ` \
    -e '/DISABLEDdata-lang="ebnf"/,/<\/code>/ s|<t>([A-Za-z0-9]+)</t>.*|<pr>\1</pr>|'  \
    \
     ${OUTPUT_ROOT}/*.html

sed -E -i .bak \
    -e 's,<pd>([^<>]*)</pd>,<a name="\1"></a>\1,' \
    \
     ${OUTPUT_ROOT}/*.html

(
cat  ${WORK_ROOT}/NameToFileMap.tmp | uniq |
    while read name file ; do
       echo "s,<t>${name}</t>,<a href="${file}#${name}">${name}</a>,g"
    done
) >${WORK_ROOT}/TempSed.tmp


sed -E -i .bak \
     -f  ${WORK_ROOT}/TempSed.tmp \
    \
     ${OUTPUT_ROOT}/*.html
