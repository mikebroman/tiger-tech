<?xml version="1.0" encoding="UTF-8"?>
<!-- Mike Broman | October 11, 2026 | TigerTech XML Assignment 3 -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:prod="http://tigertech.example/products"
    xmlns:cat="http://tigertech.example/categories"
    xmlns:tt="http://tigertech.example/functions"
    exclude-result-prefixes="xs prod cat tt">

  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

  <!-- the two files used for product and category lookups -->
  <xsl:variable name="products" select="document('products.xml')"/>
  <xsl:variable name="categories" select="document('categories.xml')"/>

  <xsl:function name="tt:money" as="xs:string">
    <xsl:param name="amount" as="xs:decimal"/>
    <xsl:sequence select="format-number($amount, '$#,##0.00')"/>
  </xsl:function>

  <xsl:template match="/orders">
    <html lang="en">
      <head>
        <title>TigerTech - Order Report</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            max-width: 1000px;
            margin: 24px auto;
            padding: 0 20px;
            line-height: 1.5;
            background: #f6f6f4;
            color: #0b2341;
          }

          header {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 20px;
            background: #0b2341;
            color: white;
            border-bottom: 5px solid #e86100;
          }

          header img {
            width: 68px;
            height: 68px;
            flex-shrink: 0;
          }

          h1 {
            margin: 0;
            font-size: 28px;
          }

          .generated {
            margin: 6px 0 0;
            font-size: 14px;
          }

          h2 {
            margin: 28px 0 12px;
            padding-bottom: 6px;
            border-bottom: 2px solid #e86100;
          }

          h3 {
            margin: 0 0 8px;
          }

          .order {
            background: white;
            padding: 16px;
            margin-bottom: 20px;
            border-left: 3px solid #e86100;
            overflow-x: auto;
          }

          .order p {
            margin: 0 0 12px;
          }

          table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            margin-bottom: 20px;
          }

          th,
          td {
            border: 1px solid #d5dbe1;
            padding: 9px 12px;
            text-align: left;
          }

          thead th {
            background: #0b2341;
            color: white;
          }

          tbody tr:nth-child(even) {
            background: #f6f7f9;
          }

          tfoot {
            background: #eef1f4;
            font-weight: bold;
          }

          .order table {
            margin-bottom: 0;
          }

          .warning {
            color: #8b2d0b;
            background: #fff2e6;
            font-weight: bold;
            padding: 2px 4px;
          }
        </style>
      </head>
      <body>
        <header>
          <img src="https://cdn.auburn.edu/assets/icons/brand_elements/au_logo/au_logo_orange_circle_whiteoutline.svg"
              alt="Auburn University logo" width="68" height="68"/>
          <div>
            <h1>TigerTech Order Report</h1>
            <p class="generated">Generated on <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/></p>
          </div>
        </header>

        <h2>Order summary</h2>
        <table>
          <thead>
            <tr><th>Order</th><th>Customer</th><th>Date</th><th>Items</th></tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="order" mode="summary">
              <xsl:sort select="@date"/>
            </xsl:apply-templates>
          </tbody>
        </table>

        <h2>Order details</h2>
        <xsl:apply-templates select="order">
          <xsl:sort select="@date"/>
        </xsl:apply-templates>

        <h2>Revenue by category</h2>
        <table>
          <thead>
            <tr><th>Category</th><th>Revenue</th></tr>
          </thead>
          <tbody>
            <!-- Save the line's SKU so the product lookup uses the right value. -->
            <xsl:for-each-group select="order/line"
                group-by="for $sku in @sku return $products/prod:catalog/prod:product[@sku = $sku]/@category">
              <xsl:sort select="current-grouping-key()"/>
              <xsl:variable name="category" select="current-grouping-key()"/>
              <xsl:variable name="revenue" select="sum(for $l in current-group() return
                xs:decimal($products/prod:catalog/prod:product[@sku = $l/@sku]/prod:price)
                * xs:decimal($l/@qty))"/>
              <tr>
                <td><xsl:value-of select="$categories/cat:categories/cat:category[@catID = $category]/cat:name"/></td>
                <td><xsl:value-of select="tt:money($revenue)"/></td>
              </tr>
            </xsl:for-each-group>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>

  <!-- SUMMARY VIEW -->
  <xsl:template match="order" mode="summary">
    <tr>
      <td><xsl:value-of select="@orderID"/></td>
      <td><xsl:value-of select="@customer"/></td>
      <td><xsl:value-of select="format-date(xs:date(@date), '[MNn] [D], [Y]')"/></td>
      <td><xsl:value-of select="sum(line/@qty)"/></td>
    </tr>
  </xsl:template>

  <!-- DETAILED VIEW -->
  <xsl:template match="order">
    <xsl:variable name="order-total" select="sum(for $l in line return
      xs:decimal($products/prod:catalog/prod:product[@sku = $l/@sku]/prod:price)
      * xs:decimal($l/@qty))"/>

    <div class="order">
      <h3><xsl:value-of select="@orderID"/></h3>
      <p>
        Customer: <xsl:value-of select="@customer"/><br/>
        Date: <xsl:value-of select="format-date(xs:date(@date), '[MNn] [D], [Y]')"/>
      </p>
      <table>
        <thead>
          <tr>
            <th>Product</th><th>Category</th><th>Unit price</th>
            <th>Quantity</th><th>Line total</th><th>Stock check</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="line">
            <xsl:variable name="p"
                select="$products/prod:catalog/prod:product[@sku = current()/@sku]"/>
            <xsl:variable name="price" select="xs:decimal($p/prod:price)"/>
            <xsl:variable name="quantity" select="xs:decimal(@qty)"/>
            <tr>
              <td><xsl:value-of select="$p/prod:name"/></td>
              <td><xsl:value-of select="$categories/cat:categories/cat:category[@catID = $p/@category]/cat:name"/></td>
              <td><xsl:value-of select="tt:money($price)"/></td>
              <td><xsl:value-of select="@qty"/></td>
              <td><xsl:value-of select="tt:money($price * $quantity)"/></td>
              <td>
                <xsl:if test="$quantity &gt; $p/prod:stock">
                  <span class="warning">Only <xsl:value-of select="$p/prod:stock"/> in stock</span>
                </xsl:if>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
        <tfoot>
          <tr>
            <th colspan="3">Total items</th>
            <td><xsl:value-of select="sum(line/@qty)"/></td>
            <td colspan="2"></td>
          </tr>
          <tr>
            <th colspan="4">Order total</th>
            <td><xsl:value-of select="tt:money($order-total)"/></td>
            <td></td>
          </tr>
        </tfoot>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
