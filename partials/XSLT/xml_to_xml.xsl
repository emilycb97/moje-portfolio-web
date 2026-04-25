<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ex="http://exslt.org/dates-and-times"
                extension-element-prefixes="ex">
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="groupById" match="group" use="@IDG"/>
  <xsl:key name="memberById" match="idol" use="@IDI"/>
  <xsl:key name="agencyById" match="agency" use="@IDA"/>

  <xsl:template match="/">
    <report>
      <idols>
        <xsl:apply-templates select="//idol"/>
      </idols>
      <groups>
        <xsl:apply-templates select="//group"/>
      </groups>
      <summary>
        <!-- Podstawowe statystyki -->
        <totalIdols>
          <xsl:value-of select="count(//idol)"/>
        </totalIdols>
        <totalGroups>
          <xsl:value-of select="count(//group)"/>
        </totalGroups>

        <!-- Największa i najmniejsza grupa -->
        <largestGroup>
          <xsl:for-each select="//group">
            <xsl:sort select="@numberOfMembers" order="descending" data-type="number"/>
            <xsl:if test="position() = 1">
              <xsl:variable name="maxValue" select="@numberOfMembers"/>
              <xsl:variable name="totalGroups" select="count(//group[@numberOfMembers = $maxValue])"/>
              <xsl:for-each select="//group[@numberOfMembers = $maxValue]">
                <xsl:value-of select="nameG"/>
                <xsl:if test="position() &lt; $totalGroups">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
          </xsl:for-each>
        </largestGroup>

        <smallestGroups>
          <xsl:for-each select="//group">
            <xsl:sort select="@numberOfMembers" data-type="number"/>
            <xsl:if test="position() = 1">
              <xsl:variable name="minValue" select="@numberOfMembers"/>
              <xsl:variable name="totalGroups" select="count(//group[@numberOfMembers = $minValue])"/>
              <xsl:for-each select="//group[@numberOfMembers = $minValue]">
                <xsl:value-of select="nameG"/>
                <xsl:if test="position() &lt; $totalGroups">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
          </xsl:for-each>
        </smallestGroups>

        <!-- Najstarsza i najmłodsza grupa -->
        <oldestGroup>
          <xsl:for-each select="//group">
            <xsl:sort select="concat(substring(@dateOfDebut, 7, 4), '-', substring(@dateOfDebut, 4, 2), '-', substring(@dateOfDebut, 1, 2))"/>
            <xsl:if test="position() = 1">
              <xsl:value-of select="nameG"/>
            </xsl:if>
          </xsl:for-each>
        </oldestGroup>

        <youngestGroup>
          <xsl:for-each select="//group">
            <xsl:sort select="concat(substring(@dateOfDebut, 7, 4), '-', substring(@dateOfDebut, 4, 2), '-', substring(@dateOfDebut, 1, 2))" order="descending"/>
            <xsl:if test="position() = 1">
              <xsl:value-of select="nameG"/>
            </xsl:if>
          </xsl:for-each>
        </youngestGroup>

        <!-- Liczby grup według płci -->
        <totalBoysGroups>
          <xsl:value-of select="count(//group[gender/@whatGender='boys'])"/>
        </totalBoysGroups>
        <totalGirlsGroups>
          <xsl:value-of select="count(//group[gender/@whatGender='girls'])"/>
        </totalGirlsGroups>
        <totalMixedGroups>
          <xsl:value-of select="count(//group[gender/@whatGender='mixed'])"/>
        </totalMixedGroups>

        <!-- Najwyższy i najniższy idol -->
        <tallestIdol>
          <xsl:value-of select="(//idol[not(height &lt; //idol/height)])[1]/stageName"/>
        </tallestIdol>
        <shortestIdol>
          <xsl:value-of select="(//idol[not(height &gt; //idol/height)])[1]/stageName"/>
        </shortestIdol>

        <!-- Najstarszy i najmłodszy idol -->
        <oldestIdol>
          <xsl:for-each select="//idol">
            <xsl:sort select="concat(substring(@dateOfBirth, 7, 4), '-', substring(@dateOfBirth, 4, 2), '-', substring(@dateOfBirth, 1, 2))" />
            <xsl:if test="position() = 1">
              <xsl:value-of select="stageName"/>
            </xsl:if>
          </xsl:for-each>
        </oldestIdol>

        <youngestIdol>
          <xsl:for-each select="//idol">
            <xsl:sort select="concat(substring(@dateOfBirth, 7, 4), '-', substring(@dateOfBirth, 4, 2), '-', substring(@dateOfBirth, 1, 2))" order="descending"/>
            <xsl:if test="position() = 1">
              <xsl:value-of select="stageName"/>
            </xsl:if>
          </xsl:for-each>
        </youngestIdol>

        <!-- Najczęstsze wartości -->
        <mostFrequentZodiacSign>
          <xsl:variable name="zodiacSigns" select="//idol/zodiacSign"/>
          <xsl:for-each select="$zodiacSigns">
            <xsl:sort select="." order="descending"/>
            <xsl:if test="position() = 1">
              <xsl:value-of select="."/>
            </xsl:if>
          </xsl:for-each>
        </mostFrequentZodiacSign>

        <mostFrequentMBTI>
          <xsl:variable name="mbtis" select="//idol/mbti"/>
          <xsl:for-each select="$mbtis">
            <xsl:sort select="." order="descending"/>
            <xsl:if test="position() = 1">
              <xsl:value-of select="."/>
            </xsl:if>
          </xsl:for-each>
        </mostFrequentMBTI>

        <!-- Autor raportu -->
        <author>
          <name>
            <xsl:value-of select="//metadata/authorName"/>
          </name>
          <surname>
            <xsl:value-of select="//metadata/authorSurname"/>
          </surname>
        </author>

        <!-- Data modyfikacji -->
        <modificationDate>
          <xsl:value-of select="substring(ex:date-time(), 1, 10)"/>
        </modificationDate>
      </summary>
    </report>
  </xsl:template>

  <!-- Templates for idol and group -->
  <xsl:template match="idol">
    <idol>
      <stageName><xsl:value-of select="stageName"/></stageName>
      <xsl:for-each select="nameI">
        <name><xsl:value-of select="."/></name>
      </xsl:for-each>
      <surname><xsl:value-of select="surname"/></surname>
      <dateOfBirth><xsl:value-of select="@dateOfBirth"/></dateOfBirth>
      <group>
        <xsl:value-of select="key('groupById', inGroup/@IDRefG)/nameG"/>
      </group>
      <height unit="{height/@unit}"><xsl:value-of select="height"/></height>
      <zodiacSign><xsl:value-of select="zodiacSign"/></zodiacSign>
      <mbti><xsl:value-of select="mbti"/></mbti>
      <xsl:for-each select="nationality">
        <nationality><xsl:value-of select="."/></nationality>
      </xsl:for-each>
      <instagram><xsl:value-of select="instagram"/></instagram>
    </idol>
  </xsl:template>

  <xsl:template match="group">
    <group>
      <nameG><xsl:value-of select="nameG"/></nameG>
      <difName><xsl:value-of select="difName"/></difName>
      <gender>
        <xsl:attribute name="whatGender">
          <xsl:value-of select="gender/@whatGender"/>
        </xsl:attribute>
      </gender>
      <fandom><xsl:value-of select="fandom"/></fandom>
      <numberOfMembers><xsl:value-of select="@numberOfMembers"/></numberOfMembers>
      <dateOfDebut><xsl:value-of select="@dateOfDebut"/></dateOfDebut>
      <agency>
        <xsl:value-of select="key('agencyById', inAgency/@IDRefA)/nameA"/>
      </agency>
      <websiteG><xsl:value-of select="websiteG"/></websiteG>
      <instagramG><xsl:value-of select="instagramG"/></instagramG>
      <twitterX><xsl:value-of select="twitterX"/></twitterX>
      <tiktok><xsl:value-of select="tiktok"/></tiktok>
      <youtube><xsl:value-of select="youtube"/></youtube>
      <spotify><xsl:value-of select="spotify"/></spotify>
    </group>
  </xsl:template>
</xsl:stylesheet>
