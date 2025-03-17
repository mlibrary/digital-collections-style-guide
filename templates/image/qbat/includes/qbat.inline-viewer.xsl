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
  <xsl:variable name="has-plain-text" select="$manifest/@has-plain-text" />
  <xsl:variable name="has-page-text">
    <xsl:choose>
      <xsl:when test="normalize-space(//qui:block[@slot='record']//qui:field[@iiif-plaintext='true']) != ''">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="notiles">
    <xsl:choose>
      <xsl:when test="$manifest/@data-cc = 'eebo' or $manifest/@data-cc = 'eebo2'">true</xsl:when>
      <xsl:when test="$manifest/@data-cc = 'ecco'">true</xsl:when>
      <xsl:when test="$manifest/@data-cc = 'evans'">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="mode" select="$manifest/@mode" />

  <xsl:template match="/" mode="add-header-tags">
    <script>
      window.mUse = window.mUse || [];
      window.mUse.push('sl-resize-observer', 'sl-dropdown', 'sl-menu', 'sl-menu-item', 'sl-dialog', 'sl-split-panel', 'sl-tab-group');
    </script>

    <script src="/uplift-viewer/dist/js/inline.js"></script>
  </xsl:template>

  <xsl:template name="build-entry-scripts">

    <script>
      window.mUse = window.mUse || [];
      window.mUse.push('sl-resize-observer', 'sl-dropdown', 'sl-menu', 'sl-menu-item', 'sl-dialog', 'sl-split-panel', 'sl-tab-group');
    </script>

    <script src="/uplift-viewer/dist/js/inline.js"></script>

  </xsl:template>

  <xsl:template name="build-asset-inline-viewer" match="qui:viewer[@viewer-mode='inline'][@access='allowed']" priority="101">
    <div class="viewer" 
      data-canvas-index="{$manifest/@canvas-index}"
      data-cc="{$manifest/@data-cc}"
      data-entryid="{$manifest/@data-entryid}"
      data-viewid="{$manifest/@data-viewid}"
      data-has-ocr="{$manifest/@has-ocr}"
      data-has-page-text="{$has-page-text}"
      >
      <xsl:if test="@viewer-advisory='true'">
        <xsl:attribute name="data-viewer-advisory">true</xsl:attribute>
      </xsl:if>
      <div class="inline--viewer">
        <sl-resize-observer data-layout-initialized="false">
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
      <xsl:if test="@viewer-advisory = 'true'">
        <div class="viewer--viewer-advisory">
          <div class="viewer-advisory-message">
            <xsl:call-template name="build-viewer-advisory-message">
              <xsl:with-param name="mode">verbose</xsl:with-param>
            </xsl:call-template>  
          </div>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="build-asset-viewer-viewer">
    <div class="viewer--panes">
      <div class="split-panels--wrap">
        <sl-split-panel style="--divider-width: 8px;">
          <xsl:attribute name="position">
            <xsl:choose>
              <xsl:when test="$has-page-text = 'false'">100</xsl:when>
              <xsl:when test="$has-plain-text = 'true'">60</xsl:when>
              <xsl:otherwise>100</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="$has-plain-text = 'false'">
            <xsl:attribute name="data-collapsed">true</xsl:attribute>
          </xsl:if>
          <xsl:if test="$has-page-text = 'false'">
            <xsl:attribute name="data-collapsed">true</xsl:attribute>
          </xsl:if>
          <sl-icon slot="divider" name="grip-vertical"></sl-icon>
          <div class="flex pane" slot="start" data-slot="viewer">
            <xsl:call-template name="build-seadragon-viewer" />
          </div>
          <div slot="end" class="pane">
            <!-- flex is only present if there's no plaintext -->
            <div class="plaintext-wrap" role="region" tabindex="0">
              <!-- <xsl:call-template name="build-annotation-tools" />
              <xsl:call-template name="build-highlight-tools" /> -->
              <div data-slot="content" class="fullview-main">
                <xsl:call-template name="build-ocr-warning-alert" />
                <xsl:apply-templates select="//qui:section//qui:field[@iiif-plaintext='true']" mode="plaintext" />
              </div>
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
      <xsl:variable name="total-canvases" select="$manifest/@total-canvases" />
      <xsl:if test="$total-canvases &gt; 1">
        <div class="toolbar-separator"></div>
        <div class="flex flex-flow-row flex-row flex-align-center jump-to-seq">
          <label for="jumpToSeq" class="col-form-label">#</label>
          <input name="seq" id="jumpToSeq" type="text" autocomplete="off" value="{$manifest/@canvas-index}" />
          <span> / <xsl:value-of select="$total-canvases" /></span>
        </div>
        <div 
          class="flex flex-flow-row flex-row flex-align-center" 
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
    <div data-class="viewer--sidebar order-1" data-slot="guide">
      <xsl:attribute name="class">
        <xsl:text>viewer--sidebar order-1</xsl:text>
        <xsl:if test="$mode = 'single'">
          <xsl:text> hidden</xsl:text>
        </xsl:if>  
      </xsl:attribute>
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

  <xsl:template name="build-annotation-tools">
    <div class="annotations-panel" style="display: none;">
      <h2 id="annotations-label" class="[ subtle-heading ][ text-black js-toc-ignore visually-hidden ]">Annotations Tools</h2>
      <div class="annotations-tools flex flex-flow-column gap-0_5 mb-1">
        <button id="action-toggle-annotations" class="button button--ghost m-0">
          <span class="material-icons" aria-hidden="true">visibility</span>
          <span>Show annotations</span>
        </button>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-highlight-tools">
    <div id="highlight-tools-toolbar">
      <xsl:attribute name="class">
        <xsl:text>highlight-tools flex flex-flow-row mb-1 justify-end </xsl:text>
        <xsl:if test="not($manifest/qui:block[@slot='plaintext']//tei:Highlight)">hidden</xsl:if>
      </xsl:attribute>
      <div class="highlight-tools-toolbar flex flex-flow-row gap-0_25">
        <sl-tooltip content="First matched term">
          <a href="#hl1" class="button button--ghost button--square m-0">
            <span class="material-icons" aria-hidden="true">arrow_forward</span>
            <span class="visually-hidden">First matched term</span>
          </a>
        </sl-tooltip>
        <sl-tooltip content="Toggle highlights">
          <button id="action-toggle-highlight" 
            class="button button--ghost button--square m-0" 
            aria-label="Toggle highlights"
            >
            <span class="material-icons" aria-hidden="true">visibility</span>
          </button>
        </sl-tooltip>
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
      data-image-id="{$image-id}"
      data-service-profile="{$resource//fn:map[@key='service']/fn:string[@key='profile']}"
      data-tile-source="{$image-id}/info.json"
      >
      <xsl:attribute name="class">
        <xsl:text>mb-0</xsl:text>
        <xsl:if test="$manifest/@canvas-index = position()">
          <xsl:text> active</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <a 
        data-canvas-index="{position()}" 
        data-canvas-label="{$canvas-label}"
        data-collid="{node()[@key='dlxs-collid']}"
        data-entryid="{node()[@key='dlxs-entryid']}"
        data-viewid="{node()[@key='dlxs-viewid']}"
        data-height="{fn:number[@key='height']}"
        data-width="{fn:number[@key='width']}"
        class="button flex flex-flow-row flex-row flex-start w-100 canvas" 
        style="gap: 1rem;" 
        data-type="button">
        <xsl:attribute name="href">
          <xsl:text>/cgi/i/image/image-idx?cc=</xsl:text>
          <xsl:value-of select="node()[@key='dlxs-collid']" />
          <xsl:text>;entryid=</xsl:text>
          <xsl:value-of select="node()[@key='dlxs-entryid']" />
          <xsl:text>;viewid=</xsl:text>
          <xsl:value-of select="node()[@key='dlxs-viewid']" />
          <xsl:text>;view=entry</xsl:text>
          <xsl:if test="//qui:root/@prep = 'true'">
            <xsl:text>;prep=1</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <div class="sequence-badge">
          <span class="visually-hidden">Scan </span>
          <span><span aria-hidden="true">#</span> <xsl:value-of select="position()" /></span>
        </div>
        <div class="flex flex-flow-column" style="align-items: flex-start">
          <xsl:if test="$notiles = 'false'">
            <div style="flex-basis: 50px; flex-shrink: 0;" class="flex justify-end">
              <img loading="lazy" src="{$image-id}/full/,150/0/default.jpg" alt="" class="border" style="width: 50px; aspect-ratio: {$ratio}" />
            </div>
          </xsl:if>
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
                  <xsl:variable name="node" select="fn:map[@key='service'][fn:string[@key='profile'][. = 'dlxs:tei:navigation']]/fn:string[@key='@id']" />
                  <fn:string node="{$node}" canvas-index="{position()}" key="{fn:string[@key='data-seq']}"><xsl:value-of select="fn:string[@key='@id']" /></fn:string>
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
    <xsl:variable name="canvas-index" select="exsl:node-set($canvases)//fn:string[. = $ranges[1]]/@canvas-index" />
    <xsl:variable name="node" select="exsl:node-set($canvases)//fn:string[. = $ranges[1]]/@node" />
    <li data-seq="{$seq}">
      <xsl:attribute name="class">
        <xsl:text>p-0 mb-0</xsl:text>
        <xsl:if test="exsl:node-set($canvases)//fn:string[. = $ranges]/@canvas-index = $manifest/@canvas-index">
          <xsl:text> active</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <a 
        data-canvas-index="{$canvas-index}"
        data-node="{$node}"
        class="button canvas flex text-xxx-small" data-type="button">
        <xsl:attribute name="href">
          <xsl:text>/cgi/t/text/pageviewer-idx?cc=</xsl:text>
          <xsl:value-of select="$manifest/@data-cc" />
          <xsl:text>;idno=</xsl:text>
          <xsl:value-of select="$manifest/@data-idno" />
          <xsl:if test="normalize-space($node)">
            <xsl:text>;node=</xsl:text>
            <xsl:value-of select="$node" />
          </xsl:if>
          <xsl:text>;rgn=</xsl:text>
          <xsl:value-of select="$manifest/@data-rgn" />
          <xsl:text>;seq=</xsl:text>
          <xsl:value-of select="$seq" />
          <xsl:text>;view=image</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="data-canvas-indexes">
          <xsl:for-each select="$ranges">
            <xsl:variable name="this" select="." />
            <xsl:value-of select="concat(':', exsl:node-set($canvases)//fn:string[. = $this]/@canvas-index, ':')" />
          </xsl:for-each>
        </xsl:attribute>
        <xsl:value-of select="fn:string[@key='label']" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="build-asset-viewer-toolbar">
    <div class="header flex flex-flow-row flex-row flex-align-center flex-space-between">
      <span style="max-width: 50%"></span>
      <div class="header--controls flex flex-flow-row flex-row flex-align-center justify-end">
        <div class="toggle--group">
          <xsl:if test="$manifest/@total-canvases &gt; 1 or $has-plain-text = 'true'">
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
            <div>
              <xsl:attribute name="class">
                <xsl:text>toggle </xsl:text>
                <xsl:choose>
                  <xsl:when test="$has-page-text = 'false'">
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>toggled</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <sl-tooltip content="Toggle text">
                <button data-action="toggle-text" class="button button--ghost" type="button">
                  <xsl:choose>
                    <xsl:when test="$has-page-text = 'false'">
                      <xsl:attribute name="disabled">true</xsl:attribute>
                      <xsl:attribute name="aria-pressed">true</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="aria-pressed">true</xsl:attribute>
                    </xsl:otherwise>
                  </xsl:choose>
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

  <xsl:template match="tei:NOTES[normalize-space(.)]">
    <section class="[ records ]">
      <h2 id="notes" class="subtle-heading">Notes</h2>
      <ul class="list-unstyled">
        <xsl:for-each select="tei:NOTE">
          <li class="mb-2 p-1 border-bottom" data-id="{node()/@ID}">
            <xsl:apply-templates select="*" mode="note" />
          </li>
        </xsl:for-each>
      </ul>
    </section>
  </xsl:template>

  <xsl:template match="qui:field[@iiif-plaintext='true']" priority="101" />

  <xsl:template match="qui:field" mode="plaintext">
    <section>
      <xsl:choose>
        <xsl:when test="qui:label">
          <h3><xsl:value-of select="qui:label" /></h3>
        </xsl:when>
        <xsl:otherwise />
      </xsl:choose>
      <xsl:for-each select="qui:values/qui:value">
        <p>
          <xsl:apply-templates select="." mode="copy-guts" />
        </p>
      </xsl:for-each>
    </section>
  </xsl:template>

</xsl:stylesheet>