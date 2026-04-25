<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

    <xsl:template match="/">

        <xsl:text>&#10;Idols:</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>===========================================================================================================================================================</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>| Stage Name         | Name         | Surname  | Date of Birth | Group               | Nationality  | Height (cm) | Zodiac Sign | MBTI | Instagram        |</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>===========================================================================================================================================================</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:for-each select="report/idols/idol">
            <!-- Formatowanie każdego rekordu -->
            <xsl:value-of select="concat(
                '| ',
                stageName,
                substring('                    ', 1, 18 - string-length(stageName)),
                ' | ',
                name,
                substring('             ', 1, 12 - string-length(name)),
                ' | ',
                surname,
                substring('             ', 1, 8 - string-length(surname)),
                ' | ',
                dateOfBirth,
                substring('             ', 1, 13 - string-length(dateOfBirth)),
                ' | ',
                group,
                substring('                    ', 1, 19 - string-length(group)),
                ' | ',
                nationality,
                substring('             ', 1, 12 - string-length(nationality)),
                ' | ',
                height,
                substring('             ', 1, 11 - string-length(height)),
                ' | ',
                zodiacSign,
                substring('             ', 1, 11 - string-length(zodiacSign)),
                ' | ',
                mbti,
                substring('             ', 1, 4 - string-length(mbti)),
                ' | '
            )"/>

            <xsl:choose>
            <xsl:when test="string-length(instagram) > 0">
                <xsl:value-of select="concat(instagram, substring('             ', 1, 16 - string-length(instagram)), ' |')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'                 |'"/>
            </xsl:otherwise>
        </xsl:choose>

            <xsl:text>&#10;</xsl:text>
            <xsl:text>-----------------------------------------------------------------------------------------------------------------------------------------------------------</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>


        <!-- Tabela grup -->
        <xsl:text>&#10;&#10;Groups:</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>=============================================================================================================</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>| Group Name           | Fandom       | Members  | Debut Date   | Agency             | Instagram            |</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>=============================================================================================================</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:for-each select="report/groups/group">
            <xsl:value-of select="concat(
                '| ',
                nameG,
                substring('                    ', 1, 20 - string-length(nameG)),
                ' | ',
                fandom,
                substring('             ', 1, 12 - string-length(fandom)),
                ' | ',
                numberOfMembers,
                substring('         ', 1, 8 - string-length(numberOfMembers)),
                ' | ',
                dateOfDebut,
                substring('             ', 1, 12 - string-length(dateOfDebut)),
                ' | ',
                agency,
                substring('                    ', 1, 18 - string-length(agency)),
                ' | ',
                instagramG,
                substring('             ', 1, 20 - string-length(instagramG)),
                ' |'
            )"/>

            <xsl:text>&#10;</xsl:text>
            <xsl:text>-------------------------------------------------------------------------------------------------------------</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>

        <!-- Podsumowanie -->
        <xsl:text>&#10;&#10;Summary:</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>=====================================================</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>| Attribute                | Value                  |</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>=====================================================</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:for-each select="report/summary/*[not(self::author) and not(self::modificationDate)]">
            <xsl:value-of select="concat(
                '| ',
                name(),
                substring('                          ', 1, 24 - string-length(name())),
                ' | ',
                .,
                substring('                          ', 1, 22 - string-length(.)),
                ' |'
            )"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>-----------------------------------------------------</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>

        <!-- Tabela autora i daty modyfikacji -->
        <xsl:text>&#10;&#10;Author and modification date:</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>===============================================</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>| Attribute          | Value                  |</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>===============================================</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:for-each select="report/summary/author/*">
            <xsl:value-of select="concat(
                '| ',
                name(),
                substring('                  ', 1, 18 - string-length(name())),
                ' | ',
                .,
                substring('                          ', 1, 22 - string-length(.)),
                ' |'
            )"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>-----------------------------------------------</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>

        <xsl:value-of select="concat(
            '| Modification Date  | ',
            report/summary/modificationDate,
            substring('                          ', 1, 22 - string-length(report/summary/modificationDate)),
            ' |'
        )"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>-----------------------------------------------</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
