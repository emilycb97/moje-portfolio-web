<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg">
    <xsl:output method="xml" indent="yes"/>

    <!-- Main template -->
    <xsl:template match="/">
        <svg:svg width="800" height="500" viewBox="0 0 800 500" onload="initChart()">
            <!-- Definitions -->
            <svg:defs>
                <!-- Gradient for background -->
                <svg:linearGradient id="backgroundGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                    <svg:stop offset="0%" style="stop-color:rgb(240, 255, 240);stop-opacity:1"/>
                    <svg:stop offset="100%" style="stop-color:rgb(220, 255, 220);stop-opacity:1"/>
                </svg:linearGradient>

                <!-- Gradient for bars -->
                <svg:linearGradient id="barGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                    <svg:stop offset="0%" style="stop-color:#A8E6A3;stop-opacity:1">
                        <svg:animate attributeName="stop-color"
                                     values="#A8E6A3;#7BC47F;#A8E6A3"
                                     dur="3s"
                                     repeatCount="indefinite"/>
                    </svg:stop>
                    <svg:stop offset="100%" style="stop-color:#7BC47F;stop-opacity:1">
                        <svg:animate attributeName="stop-color"
                                     values="#7BC47F;#4CAF50;#7BC47F"
                                     dur="3s"
                                     repeatCount="indefinite"/>
                    </svg:stop>
                </svg:linearGradient>
            </svg:defs>

            <!-- Background with animation -->
            <svg:rect width="100%" height="100%" fill="url(#backgroundGradient)">
                <svg:animate attributeName="opacity"
                             values="0.8;1;0.8"
                             dur="5s"
                             repeatCount="indefinite"/>
            </svg:rect>

            <!-- Title with animation -->
            <svg:text x="400" y="40" font-size="20" text-anchor="middle" font-family="Arial" font-weight="bold" fill="#333">
                Distribution of K-pop Idols by Zodiac Sign
                <svg:animate attributeName="font-size"
                             values="20;22;20"
                             dur="2s"
                             repeatCount="indefinite"/>
            </svg:text>

            <!-- Axes -->
            <svg:g id="axes">
                <svg:line x1="80" y1="400" x2="720" y2="400" stroke="#333" stroke-width="2">
                    <svg:animate attributeName="x2"
                                 from="80"
                                 to="720"
                                 dur="1s"
                                 fill="freeze"/>
                </svg:line>
                <svg:line x1="80" y1="400" x2="80" y2="80" stroke="#333" stroke-width="2">
                    <svg:animate attributeName="y2"
                                 from="400"
                                 to="80"
                                 dur="1s"
                                 fill="freeze"/>
                </svg:line>
            </svg:g>

            <!-- Y-axis labels with animation -->
            <svg:g id="y-labels">
                <xsl:call-template name="y-axis-labels"/>
            </svg:g>

            <!-- Data bars -->
            <svg:g id="bars">
                <xsl:for-each select="/report/idols/idol[not(zodiacSign=preceding::zodiacSign)]">
                    <xsl:sort select="zodiacSign"/>
                    <xsl:variable name="sign" select="zodiacSign"/>
                    <xsl:variable name="count" select="count(/report/idols/idol[zodiacSign=$sign])"/>
                    <xsl:variable name="position" select="position()"/>
                    <xsl:variable name="xPos" select="80 + ($position - 1) * 65"/>
                    <xsl:variable name="barHeight" select="$count * 25"/>

                    <!-- Bar group -->
                    <svg:g id="bar-{$sign}"
                           transform="translate({$xPos}, 400)"
                           onmouseover="highlightBar('{$sign}')"
                           onmouseout="unhighlightBar('{$sign}')"
                           onclick="showDetails('{$sign}', {$count})">

                        <!-- Bar -->
                        <svg:rect
                                x="0"
                                y="-{$barHeight}"
                                width="40"
                                height="{$barHeight}"
                                fill="url(#barGradient)"
                                opacity="0.8"
                                rx="5"
                                ry="5">
                            <svg:animate attributeName="height"
                                         from="0"
                                         to="{$barHeight}"
                                         dur="1s"
                                         fill="freeze"/>
                            <svg:animate attributeName="y"
                                         from="0"
                                         to="-{$barHeight}"
                                         dur="1s"
                                         fill="freeze"/>
                        </svg:rect>

                        <!-- Count label -->
                        <svg:text
                                x="20"
                                y="-{$barHeight + 10}"
                                font-family="Arial"
                                font-size="12"
                                font-weight="bold"
                                text-anchor="middle"
                                fill="#333">
                            <xsl:value-of select="$count"/>
                        </svg:text>

                        <!-- Sign label -->
                        <svg:text
                                x="20"
                                y="20"
                                font-family="Arial"
                                font-size="10"
                                text-anchor="middle"
                                transform="rotate(45, 20, 20)">
                            <xsl:value-of select="$sign"/>
                        </svg:text>
                    </svg:g>
                </xsl:for-each>
            </svg:g>

            <!-- Details panel -->
            <svg:g id="details-panel" transform="translate(300, 200)" style="display: none">
                <svg:rect x="0" y="0" width="150" height="80" fill="white" stroke="#333" rx="10"/>
                <svg:text id="details-text" x="75" y="40" text-anchor="middle"/>
            </svg:g>

            <!-- Axis titles -->
            <svg:text x="400" y="450" font-family="Arial" font-size="14" text-anchor="middle" fill="#333">
                Zodiac Signs
            </svg:text>
            <svg:text x="40" y="250" font-family="Arial" font-size="14" text-anchor="middle" fill="#333" transform="rotate(-90, 40, 250)">
                Number of Idols
            </svg:text>

            <!-- JavaScript for interactivity -->
            <svg:script type="text/javascript">
                <![CDATA[
                function initChart() {
                    // Initialize any needed variables
                    window.currentHighlight = null;
                }

                function highlightBar(sign) {
                    const bar = document.getElementById('bar-' + sign);
                    const rect = bar.getElementsByTagName('rect')[0];
                    rect.setAttribute('opacity', '1');
                    rect.setAttribute('filter', 'brightness(1.2)');
                }

                function unhighlightBar(sign) {
                    const bar = document.getElementById('bar-' + sign);
                    const rect = bar.getElementsByTagName('rect')[0];
                    rect.setAttribute('opacity', '0.8');
                    rect.setAttribute('filter', 'none');
                }

                function showDetails(sign, count) {
                    const panel = document.getElementById('details-panel');
                    const text = document.getElementById('details-text');
                    text.textContent = `${sign}: ${count} idols`;
                    panel.style.display = 'block';

                    // Animate panel appearance
                    panel.setAttribute('opacity', '0');
                    panel.animate([
                        { opacity: 0 },
                        { opacity: 1 }
                    ], {
                        duration: 300,
                        fill: 'forwards'
                    });
                }
                ]]>
            </svg:script>
        </svg:svg>
    </xsl:template>

    <!-- Template for y-axis labels -->
    <xsl:template name="y-axis-labels">
        <xsl:for-each select="/report/idols/idol[position() &lt;= 6]">
            <xsl:variable name="yPos" select="400 - (position() * 50)"/>
            <svg:text x="70" y="{$yPos}" text-anchor="end" font-family="Arial" font-size="12" opacity="0">
                <xsl:value-of select="(position() - 1) * 2"/>
                <svg:animate attributeName="opacity"
                             from="0"
                             to="1"
                             dur="0.5s"
                             begin="{position() * 0.1}s"
                             fill="freeze"/>
            </svg:text>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
