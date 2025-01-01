<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  extension-element-prefixes="exsl">

  <xsl:variable name="manifest" select="//qui:viewer" />
  <xsl:variable name="canvases" select="$manifest//fn:array[@key='sequences']/fn:map/fn:array[@key='canvases']/fn:map" />
  <xsl:variable name="item-encoding-level" select="$manifest/@item-encoding-level" />
  <xsl:variable name="has-plain-text" select="$manifest/@has-plain-text" />

  <xsl:template name="build-extra-scripts">

    <script>
      window.mUse = window.mUse || [];
      window.mUse.push('sl-dropdown', 'sl-menu', 'sl-menu-item', 'sl-dialog', 'sl-split-panel', 'sl-tab-group');
    </script>

    <script src="/uplift-viewer/dist/js/inline.js"></script>

    <xsl:call-template
      name="build-entry-scripts" />

  </xsl:template>

  <xsl:template name="build-asset-viewer">
    <div class="viewer" 
      data-canvas-index="{$manifest/@canvas-index}"
      data-cc="{$manifest/@data-cc}"
      data-idno="{$manifest/@data-idno}"
      data-node="{$manifest/@data-node}"
      data-has-ocr="{$manifest/@has-ocr}"
      data-rgn="{$manifest/@data-rgn}"
      data-item-encoding-level="{$manifest/@item-encoding-level}">
      <div class="inline--viewer">
        <sl-resize-observer>
          <div class="viewer--container">
            <xsl:call-template name="build-asset-viewer-toolbar" />
            <div class="pane--group">
              <div class="pane--viewer order-2">
                <xsl:call-template name="build-asset-viewer-viewer" />
              </div>
              <xsl:call-template name="build-asset-viewer-guide" />
            </div>
          </div>
        </sl-resize-observer>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-asset-viewer-viewer">
    <div class="viewer--panes">
      <div class="split-panels--wrap">
        <sl-split-panel style="--divider-width: 8px;">
          <xsl:attribute name="position">
            <xsl:choose>
              <xsl:when test="$has-plain-text = 'true'">60</xsl:when>
              <xsl:otherwise>100</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="$has-plain-text = 'false'">
            <xsl:attribute name="data-collapsed">true</xsl:attribute>
          </xsl:if>
          <sl-icon slot="divider" name="grip-vertical"></sl-icon>
          <div class="flex pane" slot="start" data-slot="viewer">
            <xsl:call-template name="build-seadragon-viewer" />
          </div>
          <div slot="end" class="pane">
            <div class="plaintext-wrap flex" role="region">
              <xsl:apply-templates select="$manifest/qui:block[@slot='plaintext']//tei:ResultFragment" mode="html" />
            </div>
          </div>
        </sl-split-panel>
        <div class="fetching visible">
          <div class="loader"></div>
        </div>
      </div>
      <xsl:call-template name="build-canvas-toolbar" />
    </div>
  </xsl:template>

  <xsl:template name="build-seadragon-viewer">
    <!-- <div class="image-viewer-wrap"
    >
      <xsl:call-template name="build-image-tools" />
    </div> -->
  </xsl:template>

  <xsl:template name="build-canvas-toolbar">
    <div class="image-viewer-toolbar bg-light">
      <sl-tooltip content="Zoom in">
        <button data-action="zoomIn" type="button" class="button button--ghost button--square" aria-label="Zoom in">
          <span class="material-icons" aria-hidden="true">add_circle_outline</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Zoom out">
        <button data-action="zoomOut" type="button" class="button button--ghost button--square" aria-label="Zoom out">
          <span class="material-icons" aria-hidden="true">remove_circle_outline</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Reset zoom">
        <button data-action="home" type="button" class="button button--ghost button--square" aria-label="Reset zoom">
          <span class="material-icons" aria-hidden="true">home</span>
        </button>
      </sl-tooltip>
      <xsl:variable name="total-canvases" select="count($canvases)" />
      <xsl:if test="$total-canvases &gt; 1">
        <div class="toolbar-separator"></div>
        <div class="flex flex-flow-row flex-align-center jump-to-seq">
          <label for="jumpToSeq" class="col-form-label">#</label>
          <input name="seq" id="jumpToSeq" type="text" autocomplete="off" value="{$manifest/@canvas-index}" />
          <span> / <xsl:value-of select="$total-canvases" /></span>
        </div>
        <div 
          class="flex flex-flow-row flex-align-center" 
          dir="ltr"
          style="gap: 0.125rem">
          <sl-tooltip content="Previous item" hoist="hoist">
            <button data-action="previousCanvas" type="button" class="button button--ghost button--square" aria-label="Previous item">
              <span class="material-icons" aria-hidden="true" style="transform: rotate(-90deg);">arrow_circle_up</span>
            </button>
          </sl-tooltip>
          <sl-tooltip content="Next item" hoist="hoist">
            <button data-action="nextCanvas" type="button" class="button button--ghost button--square" aria-label="Next item">
              <span class="material-icons" aria-hidden="true" style="transform: rotate(90deg);">arrow_circle_up</span>
            </button>
          </sl-tooltip>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="build-asset-viewer-guide">
    <div class="viewer--sidebar order-1" data-slot="guide">
      <div class="guide--container">
        <sl-tab-group>
          <sl-tab slot="nav" panel="items"><xsl:value-of select="$manifest/@data-pages-type" /></sl-tab>
          <xsl:apply-templates select="$manifest//fn:array[@key='structures']" mode="tab" />
          <sl-tab-panel name="items">
            <div style="height: 100%; overflow: auto;">
              <ul id="nav-index" class="list-unstyled tab-group-ranges" style="margin: 0rem;">
                <xsl:apply-templates select="$canvases" mode="canvas" />
              </ul>
            </div>
          </sl-tab-panel>
          <xsl:apply-templates select="$manifest//fn:array[@key='structures']" mode="tab-panel" />
        </sl-tab-group>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="fn:map" mode="canvas">
    <xsl:variable name="resource" select="fn:array[@key='images']//fn:map[@key='resource']" />
    <xsl:variable name="image-id" select="$resource//fn:map[@key='service']/fn:string[@key='@id']" />
    <xsl:variable name="ratio" select="$resource/fn:number[@key='width'] div $resource/fn:number[@key='height']" />
    <!-- <xsl:variable name="canvas-label" select="fn:string[@key='label']" /> -->
    <xsl:variable name="canvas-label">
      <xsl:choose>
        <xsl:when test="normalize-space(fn:string[@key='label'])">
          <xsl:value-of select="fn:string[@key='label']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($manifest/@data-page-type, ' ', position())" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <li 
      data-tile-source="{$image-id}/info.json"
      >
      <xsl:attribute name="class">
        <xsl:text>mb-0</xsl:text>
        <xsl:if test="$manifest/@canvas-index = position()">
          <xsl:text> active</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <a href="/cgi/t/text/pageviewer-idx?cc={$manifest/@data-cc};idno={$manifest/@data-idno};node={$manifest/@data-node};rgn={$manifest/@data-rgn};seq={position()};view=image" 
        data-canvas-index="{position()}" 
        data-canvas-label="{$canvas-label}"
        class="button flex flex-flow-row flex-start w-100 canvas" 
        style="gap: 1rem;" 
        data-type="button">
        <div class="sequence-badge">
          <span class="visually-hidden">Scan </span>
          <span><span aria-hidden="true">#</span> <xsl:value-of select="position()" /></span>
        </div>
        <div class="flex flex-flow-column" style="align-items: flex-start">
          <div style="flex-basis: 50px; flex-shrink: 0;" class="flex justify-end">
            <img loading="lazy" src="{$image-id}/full/,150/0/default.jpg" alt="" class="border" style="width: 50px; aspect-ratio: {$ratio}" />
          </div>
          <p class="text-xxx-small m-0" style="font-weight: normal;">
            <xsl:value-of select="$canvas-label" />
          </p>
        </div>
      </a>
    </li>
  </xsl:template>

  <xsl:template match="fn:array[@key='structures']" mode="tab">
    <sl-tab slot="nav" panel="ranges">Index</sl-tab>
  </xsl:template>

  <xsl:template match="fn:array[@key='structures']" mode="tab-panel">
    <xsl:variable name="canvases" select="../fn:array[@key='sequences']//fn:array[@key='canvases']/fn:map" />
    <sl-tab-panel name="ranges">
      <div style="height: 100%; overflow: auto;">
        <ul id="nav-ranges" class="tab-group-ranges" style="margin: 0rem;">
          <xsl:apply-templates select="fn:map" mode="structure">
            <xsl:with-param name="canvases">
              <fn:array>
                <xsl:for-each select="$canvases">
                  <fn:string key="{position()}"><xsl:value-of select="fn:string[@key='@id']" /></fn:string>
                </xsl:for-each>
              </fn:array>
            </xsl:with-param>
          </xsl:apply-templates>
        </ul>
      </div>
    </sl-tab-panel>
  </xsl:template>

  <xsl:template match="fn:map" mode="structure">
    <xsl:param name="canvases" />
    <xsl:variable name="ranges" select="fn:array[@key='canvases']/fn:string" />
    <xsl:variable name="seq" select="exsl:node-set($canvases)//fn:string[. = $ranges[1]]/@key" />
    <li data-seq="{$seq}">
      <xsl:attribute name="class">
        <xsl:text>p-0 mb-0</xsl:text>
        <xsl:if test="exsl:node-set($canvases)//fn:string[. = $ranges]/@key = $manifest/@canvas-index">
          <xsl:text> active</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <a href="/cgi/t/text/pageviewer-idx?cc={$manifest/@data-cc};idno={$manifest/@data-idno};node={$manifest/@data-node};rgn={$manifest/@data-rgn};seq={$seq};view=image" 
        data-canvas-index="{$seq}"
        class="button canvas flex text-xxx-small" data-type="button">
        <xsl:attribute name="data-canvas-indexes">
          <xsl:for-each select="$ranges">
            <xsl:variable name="this" select="." />
            <xsl:value-of select="concat(':', exsl:node-set($canvases)//fn:string[. = $this]/@key, ':')" />
          </xsl:for-each>
        </xsl:attribute>
        <xsl:value-of select="fn:string[@key='label']" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="build-asset-viewer-toolbar">
    <div class="header flex flex-flow-row flex-align-center flex-space-between">
      <span style="max-width: 50%"></span>
      <div class="header--controls flex flex-flow-row flex-align-center justify-end">
        <div class="toggle--group">
          <xsl:if test="count($canvases) &gt; 1 or $has-plain-text = 'true'">
            <div class="toggle toggled">
              <sl-tooltip content="Toggle guide">
                <button data-action="toggle-guide" class="button button--ghost" aria-pressed="true" type="button">
                  <span class="material-icons" aria-hidden="true">view_list</span>
                  <span>Guide</span>
                </button>
              </sl-tooltip>
            </div>
          </xsl:if>
          <xsl:if test="$has-plain-text = 'true'">
            <div class="toggle toggled">
              <sl-tooltip content="Toggle image">
                <button data-action="toggle-image" class="button button--ghost" aria-pressed="true" type="button">
                  <span class="material-icons" aria-hidden="true">image</span>
                  <span>Image</span>
                </button>
              </sl-tooltip>
            </div>          
            <div class="toggle toggled">
              <sl-tooltip content="Toggle text">
                <button data-action="toggle-text" class="button button--ghost" aria-pressed="true" type="button">
                  <span class="material-icons" aria-hidden="true">article</span>
                  <span>Text</span>
                </button>
              </sl-tooltip>
            </div>          
          </xsl:if>
        </div>
        <sl-tooltip content="Toggle fullscreen" data-slot="fullscreen">
          <button 
            data-action="toggle-fullscreen" 
            type="button" 
            class="button button--ghost button--square" 
            aria-label="Toggle fullscreen">
            <span class="material-icons" aria-hidden="true">fullscreen</span>
          </button>
        </sl-tooltip>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-image-tools">
    <div class="button--group image-tools-toolbar" aria-expanded="false">
      <sl-tooltip content="Rotate right" data-slot="expanded">
        <button class="button button--square button--ghost"
          aria-label="Rotate right"
          >
          <span class="material-icons" aria-hidden="true">rotate_right</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Rotate left" data-slot="expanded">
        <button class="button button--square button--ghost"
          aria-label="Rotate left"
          >
          <span class="material-icons" aria-hidden="true">rotate_left</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Flip image" data-slot="expanded">
        <button class="button button--square button--ghost" 
          aria-label="Flip image"
          >
          <span class="material-icons" aria-hidden="true">swap_horiz</span>
        </button>
      </sl-tooltip>
      <div style="position: relative;" data-slot="expanded">
        <sl-tooltip content="Adjust brightness">
          <button class="button button--square button--ghost" 
            aria-label="Adjust brightness"
            >
            <span class="material-icons" aria-hidden="true">brightness_5</span>
          </button>
        </sl-tooltip>
        <div class="image-options" data-slot="expanded">
          <input 
            name="brightness"
            aria-label="Brightness"
            type="range" 
            orient="vertical" 
            min="0" 
            max="200" 
            aria-valuetext=""
            autocomplete="off"
             />
        </div>
      </div>
      <div style="position: relative" data-slot="expanded">
        <sl-tooltip content="Adjust contrast">
          <button class="button button--square button--ghost" 
            aria-label="Adjust contrast"
            >
            <span class="material-icons" aria-hidden="true">exposure</span>
          </button>
        </sl-tooltip>
        <div class="image-options hidden">
          <input 
            name="contrast"
            aria-label="Contrast"
            type="range" 
            orient="vertical"
            min="0" 
            max="200"
            autocomplete="off"
            aria-valuetext="" 
            />
        </div>
      </div>
      <div style="position: relative" data-slot="expanded">
        <sl-tooltip content="Adjust saturation">
          <button class="button button--square button--ghost" 
            aria-label="Adjust saturation"
            >
            <span class="material-icons" aria-hidden="true">gradient</span>
          </button>
        </sl-tooltip>
        <div class="image-options hidden">
          <input 
            name="saturation"
            aria-label="Saturation"
            type="range" 
            orient="vertical" 
            min="0" 
            max="200" 
            aria-valuetext=""
            autocomplete="off"
            />
        </div>
      </div>
      <sl-tooltip content="Grayscale" data-slot="expanded">
        <button class="button button--square button--ghost" 
          aria-label="Grayscale"
          >
          <span class="material-icons" aria-hidden="true">tonality</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Invert colors" data-slot="expanded">
        <button class="button button--square button--ghost" 
          aria-label="Invert colors"
          >
          <span class="material-icons" aria-hidden="true">invert_colors</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Revert image" data-slot="expanded">
        <button class="button button--square button--ghost" aria-label="Revert image">
          <span class="material-icons" aria-hidden="true">replay</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Close tools" data-slot="expanded">
        <button class="button button--square button--ghost" aria-label="Close tools">
          <span class="material-icons" aria-hidden="true">close</span>
        </button>
      </sl-tooltip>
      <sl-tooltip content="Open tools" data-slot="collapsed">
        <button class="button button--square button--ghost" aria-label="Open tools">
          <span class="material-icons" aria-hidden="true">tune</span>
        </button>
      </sl-tooltip>
    </div>
  </xsl:template>

  <xsl:template match="tei:ResultFragment" mode="html">
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''"></xsl:when>
      <xsl:when test="$item-encoding-level = '1'">
        <xsl:if test="preceding-sibling::tei:ResultFragment">
          <hr />
        </xsl:if>    
        <section class="pre-line">
          <xsl:apply-templates />
        </section>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="preceding-sibling::tei:ResultFragment">
          <hr />
        </xsl:if>
        <article data-item-encoding-level="{$item-encoding-level}">
        <xsl:apply-templates />
        </article>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>