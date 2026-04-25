<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns="http://www.w3.org/1999/xhtml">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!-- Root Template -->
    <xsl:template match="/">
        <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>Kpop Idols - Report</title>
                <meta charset="UTF-8" />
                <link rel="stylesheet" href="style.css" type="text/css" />
            </head>
            <body>
                <h1>Kpop Idols - Report</h1>
                <xsl:apply-templates select="report/idols" />
                <xsl:apply-templates select="report/groups" />
                <xsl:apply-templates select="report/summary" />
                <xsl:apply-templates select="report/summary/author" />
            </body>
        </html>
    </xsl:template>

    <!-- Template for Idols -->
    <xsl:template match="idols">
        <section>
            <h2>Idols</h2>
            <table>
                <thead>
                    <tr>
                        <th>Stage Name</th>
                        <th>Full Name</th>
                        <th>Date of Birth</th>
                        <th>Group</th>
                        <th>Height (cm)</th>
                        <th>Zodiac Sign</th>
                        <th>MBTI</th>
                        <th>Nationalities</th>
                        <th>Instagram</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="idol">
                        <tr>
                            <td><xsl:value-of select="stageName" /></td>
                            <td>
                                <xsl:value-of select="concat(name[1], ' ', surname)" />
                                <xsl:if test="name[2]">
                                    (<xsl:value-of select="name[2]" />)
                                </xsl:if>
                            </td>
                            <td><xsl:value-of select="dateOfBirth" /></td>
                            <td><xsl:value-of select="group" /></td>
                            <td><xsl:value-of select="height" /></td>
                            <td><xsl:value-of select="zodiacSign" /></td>
                            <td><xsl:value-of select="mbti" /></td>
                            <td>
                                <xsl:for-each select="nationality">
                                    <xsl:value-of select="." />
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="string-length(instagram) &gt; 0">
                                        <a href="https://www.instagram.com/{substring(instagram, 2)}">
                                            <xsl:value-of select="instagram" />
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>None</xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </section>
    </xsl:template>

    <!-- Template for Groups -->
    <xsl:template match="groups">
        <section>
            <h2>Groups</h2>
            <table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Alternative Name</th>
                        <th>Gender</th>
                        <th>Fandom</th>
                        <th>Number of Members</th>
                        <th>Date of Debut</th>
                        <th>Agency</th>
                        <th>Official Website</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="group">
                        <tr>
                            <td><xsl:value-of select="nameG" /></td>
                            <td><xsl:value-of select="difName" /></td>
                            <td><xsl:value-of select="gender/@whatGender" /></td>
                            <td><xsl:value-of select="fandom" /></td>
                            <td><xsl:value-of select="numberOfMembers" /></td>
                            <td><xsl:value-of select="dateOfDebut" /></td>
                            <td><xsl:value-of select="agency" /></td>
                            <td>
                                <a href="{websiteG}"><xsl:value-of select="websiteG" /></a>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </section>
    </xsl:template>

    <!-- Template for Summary -->
    <xsl:template match="summary">
        <section>
            <h2>Summary</h2>
            <table>
                <thead>
                    <tr>
                        <th>Attribute</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Total Idols</td>
                        <td><xsl:value-of select="totalIdols" /></td>
                    </tr>
                    <tr>
                        <td>Total Groups</td>
                        <td><xsl:value-of select="totalGroups" /></td>
                    </tr>
                    <tr>
                        <td>Largest Group</td>
                        <td><xsl:value-of select="largestGroup" /></td>
                    </tr>
                    <tr>
                        <td>Smallest Group</td>
                        <td><xsl:value-of select="smallestGroup" /></td>
                    </tr>
                    <tr>
                        <td>Oldest Group</td>
                        <td><xsl:value-of select="oldestGroup" /></td>
                    </tr>
                    <tr>
                        <td>Youngest Group</td>
                        <td><xsl:value-of select="youngestGroup" /></td>
                    </tr>
                    <tr>
                        <td>Total Boys Groups</td>
                        <td><xsl:value-of select="totalBoysGroups" /></td>
                    </tr>
                    <tr>
                        <td>Total Girls Groups</td>
                        <td><xsl:value-of select="totalGirlsGroups" /></td>
                    </tr>
                    <tr>
                        <td>Total Mixed Groups</td>
                        <td><xsl:value-of select="totalMixedGroups" /></td>
                    </tr>
                    <tr>
                        <td>Tallest Idol</td>
                        <td><xsl:value-of select="tallestIdol" /></td>
                    </tr>
                    <tr>
                        <td>Shortest Idol</td>
                        <td><xsl:value-of select="shortestIdol" /></td>
                    </tr>
                    <tr>
                        <td>Oldest Idol</td>
                        <td><xsl:value-of select="oldestIdol" /></td>
                    </tr>
                    <tr>
                        <td>Youngest Idol</td>
                        <td><xsl:value-of select="youngestIdol" /></td>
                    </tr>
                    <tr>
                        <td>Most Frequent Zodiac Sign</td>
                        <td><xsl:value-of select="mostFrequentZodiacSign" /></td>
                    </tr>
                    <tr>
                        <td>Most Frequent MBTI</td>
                        <td><xsl:value-of select="mostFrequentMBTI" /></td>
                    </tr>
                </tbody>
            </table>
        </section>
    </xsl:template>

    <!-- Template for Author and Modification Date -->
    <xsl:template match="summary/author">
        <section>
            <h2>Author and Modification Date</h2>
            <table>
                <thead>
                    <tr>
                        <th>Author</th>
                        <th>Last Modification Date</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><xsl:value-of select="concat(name, ' ', surname)" /></td>
                        <td><xsl:value-of select="../modificationDate" /></td>
                    </tr>
                </tbody>
            </table>
        </section>
    </xsl:template>
</xsl:stylesheet>
