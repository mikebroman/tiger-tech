<?xml version="1.0" encoding="UTF-8"?>
<!-- TigerTech A3 - order report stylesheet. Namespace setup and lookup
     documents are provided. You build TWO views using modes. Fill in the TODOs. -->
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:prod="http://tigertech.example/products"
     xmlns:cat="http://tigertech.example/categories"
     exclude-result-prefixes="prod cat">

   <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

   <!-- the two files you look products/categories up in -->
   <xsl:variable name="products"   select="document('products.xml')"/>
   <xsl:variable name="categories" select="document('categories.xml')"/>

   <xsl:template match="/orders">
      <html>
         <head><title>TigerTech - Order Report</title>
            <!-- (add a little CSS here if you like) -->
         </head>
         <body>
            <h1>TigerTech Order Report</h1>

            <h2>Order summary</h2>
            <table>
               <thead><tr><th>Order</th><th>Customer</th><th>Date</th><th>Items</th></tr></thead>
               <tbody>
                  <!-- TODO A: apply templates to each <order> in mode="summary",
                       sorted by @date. -->
               </tbody>
            </table>

            <h2>Order details</h2>
            <!-- TODO B: apply templates to each <order> in the DEFAULT mode,
                 sorted by @date. -->

         </body>
      </html>
   </xsl:template>

   <!-- SUMMARY VIEW (mode="summary") -->
   <xsl:template match="order" mode="summary">
      <!-- TODO C: one <tr> showing @orderID, @customer, @date, and the number of
           items in the order (sum of the line quantities). -->
   </xsl:template>

   <!-- DETAILED VIEW (default mode) -->
   <xsl:template match="order">
      <!-- TODO 1: show this order's @orderID, @customer and @date, then a table
           of its <line> items.
           TODO 2: for each line, look its product up in $products by @sku and show
           the product's prod:name and prod:price.
           TODO 3: also show the product's category NAME (look @category up in
           $categories, match cat:category/@catID).
           TODO 4: show the line total (price x @qty); format money with
           format-number(value, '$#,##0.00').
           TODO 5: if @qty is greater than the product's prod:stock, flag it.
           TODO 6: total the items for the order (sum of the line quantities). -->
   </xsl:template>

</xsl:stylesheet>
