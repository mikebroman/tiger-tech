<?xml version="1.0" encoding="UTF-8"?>
<!-- Mike Broman | October 8, 2026 | TigerTech XML Assignment 3, Parts A and B -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:prod="http://tigertech.example/products"
    xmlns:cat="http://tigertech.example/categories"
    xmlns:tt="http://tigertech.example/functions"
    exclude-result-prefixes="xs prod cat tt">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
      doctype-system="about:legacy-compat"/>
  <xsl:strip-space elements="*"/>

  <!-- Relative document URIs resolve beside this stylesheet. -->
  <xsl:variable name="products" select="document('products.xml')"/>
  <xsl:variable name="categories" select="document('categories.xml')"/>

  <!-- A typed function can be called directly from XPath expressions. -->
  <xsl:function name="tt:money" as="xs:string">
    <xsl:param name="amount" as="xs:decimal"/>
    <xsl:sequence select="format-number($amount, '$#,##0.00')"/>
  </xsl:function>

  <xsl:template match="/orders">
    <html lang="en">
      <head>
        <title>TigerTech - Order Report</title>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <style>
          * { box-sizing: border-box; }
          body { margin: 0; background: #f3f5f7; color: #202b36;
                 font-family: Arial, Helvetica, sans-serif; line-height: 1.5; }
          main { max-width: 1100px; margin: 0 auto; padding: 32px 20px; }
          h1 { margin: 0; color: #173b57; }
          h2 { margin: 30px 0 12px; color: #173b57; }
          h3 { margin: 0 0 8px; }
          .generated, .note { color: #52606d; }
          .table-wrap { overflow-x: auto; }
          table { width: 100%; border-collapse: collapse; background: white; }
          caption { text-align: left; padding: 0 0 8px; font-weight: bold; }
          th, td { padding: 12px; border-bottom: 1px solid #dce2e7;
                   text-align: left; vertical-align: top; }
          thead th { background: #173b57; color: white; }
          .number { text-align: right; white-space: nowrap;
                    font-variant-numeric: tabular-nums; }
          tfoot th, tfoot td { background: #edf2f6; font-weight: bold; }
          .order-card { margin: 16px 0; padding: 20px; background: white;
                        border: 1px solid #dce2e7; border-radius: 8px; }
          .order-meta { margin: 0 0 16px; }
          .stock-warning { color: #8a250a; font-weight: bold; }
          .over-stock { background: #fff6ed; }
          .sku { display: block; color: #52606d; font-size: 0.85em; }
          a { color: #145781; }
          @media (max-width: 600px) {
            main { padding: 20px 12px; }
            .order-card { padding: 12px; }
            th, td { padding: 10px; }
          }
          @media print {
            body { background: white; }
            main { max-width: none; padding: 0; }
            .order-card { break-inside: avoid; }
          }
        </style>
      </head>
      <body>
        <main>
          <h1>TigerTech Order Report</h1>
          <p class="generated">
            <xsl:text>Generated on </xsl:text>
            <time datetime="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}">
              <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]', 'en', (), ())"/>
            </time>
          </p>

          <section aria-labelledby="summary-heading">
            <h2 id="summary-heading">Order summary</h2>
            <div class="table-wrap">
              <table id="order-summary">
                <caption>Orders, oldest first</caption>
                <thead>
                  <tr>
                    <th scope="col">Order</th>
                    <th scope="col">Customer</th>
                    <th scope="col">Date</th>
                    <th scope="col" class="number">Items</th>
                  </tr>
                </thead>
                <tbody>
                  <xsl:apply-templates select="order" mode="summary">
                    <xsl:sort select="@date" data-type="text" order="ascending"/>
                  </xsl:apply-templates>
                </tbody>
              </table>
            </div>
          </section>

          <section aria-labelledby="details-heading">
            <h2 id="details-heading">Order details</h2>
            <xsl:apply-templates select="order">
              <xsl:sort select="@date" data-type="text" order="ascending"/>
            </xsl:apply-templates>
          </section>

          <section aria-labelledby="revenue-heading">
            <h2 id="revenue-heading">Revenue by category</h2>
            <p class="note">Based on all ordered quantities, including lines flagged for insufficient stock.</p>
            <div class="table-wrap">
              <table id="category-revenue">
                <caption>Total order value by product category</caption>
                <thead>
                  <tr>
                    <th scope="col">Category</th>
                    <th scope="col" class="number">Revenue</th>
                  </tr>
                </thead>
                <tbody>
                  <!-- Bind the line's SKU before changing context to the catalog. -->
                  <xsl:for-each-group select="order/line"
                      group-by="for $sku in @sku return $products/prod:catalog/prod:product[@sku = $sku]/@category">
                    <xsl:sort select="$categories/cat:categories/cat:category[@catID = current-grouping-key()]/cat:name"/>
                    <xsl:variable name="revenue" as="xs:decimal"
                        select="sum(for $l in current-group() return
                          xs:decimal($products/prod:catalog/prod:product[@sku = $l/@sku]/prod:price)
                          * xs:decimal($l/@qty))"/>
                    <tr>
                      <th scope="row">
                        <xsl:value-of select="$categories/cat:categories/cat:category[@catID = current-grouping-key()]/cat:name"/>
                      </th>
                      <td class="number"><xsl:value-of select="tt:money($revenue)"/></td>
                    </tr>
                  </xsl:for-each-group>
                </tbody>
                <tfoot>
                  <tr>
                    <th scope="row">Total revenue</th>
                    <td class="number">
                      <xsl:value-of select="tt:money(sum(for $l in order/line return
                        xs:decimal($products/prod:catalog/prod:product[@sku = $l/@sku]/prod:price)
                        * xs:decimal($l/@qty)))"/>
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </section>
        </main>
      </body>
    </html>
  </xsl:template>

  <!-- First pass: one summary row per order. -->
  <xsl:template match="order" mode="summary">
    <tr>
      <td><a href="#{@orderID}"><xsl:value-of select="@orderID"/></a></td>
      <td><xsl:value-of select="@customer"/></td>
      <td>
        <time datetime="{@date}">
          <xsl:value-of select="format-date(xs:date(@date), '[MNn] [D], [Y]', 'en', (), ())"/>
        </time>
      </td>
      <td class="number"><xsl:value-of select="sum(line/@qty)"/></td>
    </tr>
  </xsl:template>

  <!-- Second pass: one detailed card per order in the default mode. -->
  <xsl:template match="order">
    <xsl:variable name="order-total" as="xs:decimal"
        select="sum(for $l in line return
          xs:decimal($products/prod:catalog/prod:product[@sku = $l/@sku]/prod:price)
          * xs:decimal($l/@qty))"/>
    <article class="order-card" id="{@orderID}" aria-labelledby="heading-{@orderID}">
      <h3 id="heading-{@orderID}"><xsl:value-of select="@orderID"/></h3>
      <p class="order-meta">
        <strong>Customer: </strong><xsl:value-of select="@customer"/>
        <br/>
        <strong>Date: </strong>
        <time datetime="{@date}">
          <xsl:value-of select="format-date(xs:date(@date), '[MNn] [D], [Y]', 'en', (), ())"/>
        </time>
      </p>
      <div class="table-wrap">
        <table class="order-lines">
          <caption>Line items for <xsl:value-of select="@orderID"/></caption>
          <thead>
            <tr>
              <th scope="col">Product</th>
              <th scope="col">Category</th>
              <th scope="col" class="number">Unit price</th>
              <th scope="col" class="number">Quantity</th>
              <th scope="col" class="number">Line total</th>
              <th scope="col">Stock check</th>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="line">
              <xsl:variable name="p"
                  select="$products/prod:catalog/prod:product[@sku = current()/@sku]"/>
              <xsl:variable name="price" as="xs:decimal" select="xs:decimal($p/prod:price)"/>
              <xsl:variable name="quantity" as="xs:decimal" select="xs:decimal(@qty)"/>
              <tr>
                <xsl:if test="$quantity &gt; xs:decimal($p/prod:stock)">
                  <xsl:attribute name="class">over-stock</xsl:attribute>
                </xsl:if>
                <th scope="row">
                  <xsl:value-of select="$p/prod:name"/>
                  <span class="sku"><xsl:value-of select="@sku"/></span>
                </th>
                <td>
                  <xsl:value-of select="$categories/cat:categories/cat:category[@catID = $p/@category]/cat:name"/>
                </td>
                <td class="number"><xsl:value-of select="tt:money($price)"/></td>
                <td class="number"><xsl:value-of select="@qty"/></td>
                <td class="number"><xsl:value-of select="tt:money($price * $quantity)"/></td>
                <td>
                  <xsl:if test="$quantity &gt; xs:decimal($p/prod:stock)">
                    <span class="stock-warning">
                      <xsl:text>Only </xsl:text>
                      <xsl:value-of select="$p/prod:stock"/>
                      <xsl:text> in stock</xsl:text>
                    </span>
                  </xsl:if>
                  <xsl:if test="$quantity &lt;= xs:decimal($p/prod:stock)">In stock</xsl:if>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
          <tfoot>
            <tr>
              <th scope="row" colspan="3">Total items</th>
              <td class="number"><xsl:value-of select="sum(line/@qty)"/></td>
              <td colspan="2"></td>
            </tr>
            <tr>
              <th scope="row" colspan="4">Order total</th>
              <td class="number"><xsl:value-of select="tt:money($order-total)"/></td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>
    </article>
  </xsl:template>
</xsl:stylesheet>
