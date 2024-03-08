#!/bin/bash

defaults="true"
subject="methods"

# command line arguments
while :; do
	case $1 in 
		--class|--classes)
			subject="classes"
			;;

		--method-list)
			subject="method-list"
			;;

		--class-list)
			subject="class-list"
			;;

		--package-list)
			subject="package-list"
			;;



		--all)
			all="true"
			defaults="false"
			;;
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
	echo "// setting defaults"
	all="false";
	failures="true";
	errors="true";
	skipped="false";
	if [ -z ${incomplete+x} ]; then
		incomplete="false";
	fi
fi
echo "// settings: all=$all, failures=$failures, errors=$errors, skipped=$skipped, incomplete=$incomplete"
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

	if [ "$all" == "true" ]; then echo "false and "; fi
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

output_classes() {
	grep "<testcase" | grep 'classname="' | sed 's/.* classname="\([^"]*\)".*/\1.class/' | awk '!seen[$0]++'
}

output_methods() {
	grep "<testcase" | grep 'classname="' | sed 's/.* name="\([^"]*\)".* classname="\([^"]*\)"\( time="\([^"]*\)"\)\?.*/\2.class\t\1\t\4/' | awk '!seen[$0]++'
}


classes() {
	cat "$1" | filter_failures | output_cases | output_classes
}

methods() {
	cat "$1" | filter_failures | output_cases | output_methods
}

class_list() {
	methods "$1" | aggregate_entries
}

# usage: <steps_to_remove_from_name>
aggregate_entries() {
	awk -v toRemove="$1" -F$'\t' '
		BEGIN {
			delete order[0]
		}
		{
			entry_time = $3
			if(toRemove > 0) {
				split($1,steps,".")
				key = ""
				for(i = 1; i<=length(steps)-toRemove; i++) {
					if(i > 1) {
						key = key "."
					}
					key = key steps[i]
				}
			}
			else {
				key = $1
			}

			if(!(key in time)) {
				cnt++;
				order[cnt] = key
				time[key] = 0
			}
			time[key] += entry_time
			next
		}
		END {
			for(i=1; i<=cnt; i++) {
				print order[i] "\t\t" time[order[i]]
			}
		}
	'
}

# generate output

if [ "$subject" == "classes" ]; then

cat <<EOF
import org.junit.runner.*;
import org.junit.runners.*;
import org.junit.runners.Suite.*;

/**
 */

@RunWith(Suite.class)
@SuiteClasses({ //
EOF

class_list "$1" | awk -F$'\t' '{print "\t" $1 ", // " $2}'

cat <<EOF
})
public class FilteredTests
{

}
EOF

elif [ "$subject" == "package-list" ]; then

	methods "$1" | aggregate_entries 2

elif [ "$subject" == "class-list" ]; then

	class_list "$1"

elif [ "$subject" == "method-list" ]; then

	methods "$1"

elif [ "$subject" == "methods" ]; then

cat <<EOF
import java.lang.annotation.*;
import java.util.*;

import org.junit.runner.*;
import org.junit.runner.manipulation.*;
import org.junit.runners.*;
import org.junit.runners.model.*;

public class FilteredTests
{

	@Retention(RetentionPolicy.RUNTIME)
	@Target(ElementType.TYPE)
	public @interface SuiteMethods {
		Method[] value() default {};
	}

	@Retention(RetentionPolicy.RUNTIME)
	@Target(ElementType.TYPE)
	@Repeatable(SuiteMethods.class)
	public static @interface Method {
		public Class<?> klass();
		public String method();
	}

	public static class MethodFilter extends Suite
	{

		private static List<List<String>> methodGroups = new ArrayList<>();
		private static List<Class<?>> classes = new ArrayList<>();

		private static List<Class<?>> getClasses(Class<?> klass) throws InitializationError
		{
			SuiteMethods annotation = klass.getAnnotation(SuiteMethods.class);
			if (annotation == null)
			{
				throw new InitializationError(String.format(
					"class '%s' must have a Method or SuiteMethods annotation",
					klass.getName()));
			}
			for (Method m : annotation.value())
			{
				// group method calls if possible
				if (classes.isEmpty()
					|| classes.get(classes.size() - 1) != m.klass()
					|| methodGroups.get(classes.size() - 1).contains(m.method()))
				{
					classes.add(m.klass());
					methodGroups.add(new ArrayList<>());
				}
				methodGroups.get(methodGroups.size() - 1).add(m.method());
			}
			return classes;
		}

		public MethodFilter(Class<?> klass, RunnerBuilder builder) throws Exception
		{
			super(klass, builder.runners(null, getClasses(klass)));
			Filter f = new Filter()
			{
				int i = 0;
				@Override
				public boolean shouldRun(Description desc)
				{
					String methodName = desc.getMethodName();
					if (methodName == null)
					{
						return true;
					}

					if (desc.getTestClass() != classes.get(this.i))
						this.i++;

					List<String> methods = methodGroups.get(this.i);
					return methods != null && methods.contains(methodName);
				}

				@Override
				public String describe()
				{
					return null;
				}
			};
			super.filter(f);
			int[] j = { 0 };
			Sorter s = new Sorter((o1, o2) -> {
				if (o1.getMethodName() == null || o2.getMethodName() == null)
					return 1;
				if (classes.get(j[0]) != o1.getTestClass())
					j[0]++;
				List<String> methods = methodGroups.get(j[0]);
				return Integer.compare(
					methods.indexOf(o1.getMethodName()),
					methods.indexOf(o2.getMethodName()));
			});

			super.sort(s);
		}
	}

	//@formatter:off
	@RunWith(MethodFilter.class)
EOF

	methods "$1" | awk -F $'\t' '
	
	BEGIN {
		sum = 0
	}

	{ 
		method = $2;
		gsub("\\\\", "\\\\\\\\", method);
		print "\t@Method(klass = " $1 ",method = \"" method "\") "  #"// time: " $3;

		if($3 != "") {
			sum += $3;
		}
	} 
	
	END {
		print "\t//\n\t// time of previous run: " sum " s\n\t//" 
	}
	'


cat <<EOF
	public static class FilteredTestSuite
	{

	}
}
EOF

fi


