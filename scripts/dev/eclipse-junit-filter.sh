#!/bin/bash

defaults="true"

# command line arguments
while :; do
	case $1 in 
		--failure|--failures)
			failures="true"
			defaults="false"
			;;
		--error|--errors)
			errors="true"
			defaults="false"
			;;
		--skipped)
			skipped="true"
			defaults="false"
			;;
		--incomplete)
			incomplete="true"
			defaults="false"
			;;
		--with-incomplete)
			incomplete="true"
			;;
		-?*)
			printf "Unknown option: %s\n" "$1" >&2
			exit
			;;
		*)
			break
	esac
	shift
done

# defaults
if [ "$defaults" == "true" ]; then
	echo "setting defaults"
	failures="true";
	errors="true";
	skipped="false";
	if [ -z ${incomplete+x} ]; then
		incomplete="false";
	fi
fi
echo "// settings: failures=$failures, errors=$errors, skipped=$skipped, incomplete=$incomplete" > /dev/stderr
echo "// --------------------------------------------------------------------------------"

filter_failures() {
	xsltproc <(cat <<EOF
	<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		<xsl:output omit-xml-declaration="no" indent="yes"/>
		<xsl:strip-space elements="*"/>

		<!-- default: copy -->
		<xsl:template match="node()|@*">
		<xsl:copy>
		<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
		</xsl:template>

		<xsl:template match="*[
EOF

	if [ "$failures" == "true" ]; then echo "not(descendant-or-self::failure) and "; fi
	if [ "$errors" == "true" ]; then echo "not(descendant-or-self::error) and "; fi
	if [ "$skipped" == "true" ]; then echo "not(descendant-or-self::skipped) and "; fi
	if [ "$incomplete" == "true" ]; then echo "not(.//@incomplete) and "; fi
cat <<EOF
			true()]"/>
	</xsl:stylesheet>
EOF

	) -
}

output_cases() {
	xsltproc <(cat <<EOF
	<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		<xsl:output omit-xml-declaration="no" indent="yes"/>
		<xsl:strip-space elements="*"/>

		<!-- default: copy -->
		<xsl:template match="node()|@*">
		<xsl:copy>
		<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
		</xsl:template>


		<xsl:template match="testcase">
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
			</xsl:copy>
		</xsl:template>

	</xsl:stylesheet>
EOF
	) -
}

# https://stackoverflow.com/a/17841619/1562506
function join_by { 
	local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}";
}

output_classes() {
	grep "<testcase" | grep 'classname="' | sed 's/.*classname="\([^"]*\)".*/\1.class/' | sort -u
}

classes() {
	cat "$1" | filter_failures | output_cases | output_classes
}

# generate output

cat <<EOF
import org.junit.runner.*;
import org.junit.runners.*;
import org.junit.runners.Suite.*;

/**
 */

@RunWith(Suite.class)
@SuiteClasses({ //
EOF

echo -n "	"

join_by ', //
	' $(classes "$1")

echo ", //"
cat <<EOF
})
public class FilteredTests
{

}
EOF

