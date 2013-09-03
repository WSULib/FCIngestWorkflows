<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:database="http://www.oclc.org/pears/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"	
	xmlns:mods="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
	xmlns:srw_dc="info:srw/schema/1/dc-schema"	
	xmlns:redirect="http://xml.apache.org/xalan/redirect" extension-element-prefixes="redirect">
<xsl:output method="xml" indent="yes"/>

<!--Loads DC to include in FOXML (same directory), as created from MODS or hand created-->
<xsl:variable name="input2" select="document('DC_from_MODS.xml')/srw_dc:dcCollection"/>

<!--Collection Specific Variables-->
<xsl:variable name="fileLocation" select="'URL OF THE access AND thumbs DIRECTORIES (e.g. http://141.217.54.38/~ej2929/fedora_dropbox/heart_transplant_images/heart_transplant/)'"/>
<!--Leave out the word "collection" from this variable, as it creates PID as well.  Automatically added for RDF statements farther down.-->
<xsl:variable name="collectionName" select="'COLLECTION NAME HERE'"/>
	

<!--
This stylesheet will perform the following:
1) extract MODS records from <mods:modsCollection> file
2) extract key values from MODS, insert into template
3) where <mods:identifier> matches <dc:identifier> in external DC records file, DC elements are inserted before writing FOXML file
4) insert MODS record wholesale into <foxml:datastream ID="MODS" STATE="A" CONTROL_GROUP="M">
5) write new FOXML file, with _______ as the filename 
-->
	
<xsl:template match="/mods:modsCollection">	
	<xsl:for-each-group select="mods:mods" group-by="mods:identifier">
		<!-- the following line determines where and by what name the files will output as / note:relative to location of XML file, not XSL -->
		<xsl:result-document href="FOXML_{normalize-space(mods:identifier)}.xml">
			
			<!--********************************************************************************************************************-->
			<!-- WSU INGEST Template -->
			<!--********************************************************************************************************************-->			
			<foxml:digitalObject xmlns:foxml="info:fedora/fedora-system:def/foxml#" VERSION="1.1"  
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xsi:schemaLocation="info:fedora/fedora-system:def/foxml#
				http://www.fedora.info/definitions/1/0/foxml1-1.xsd"><!-- sets attribute of <foxml:digitalObject--><xsl:attribute name="PID">wayne:<xsl:value-of select="$collectionName"/><xsl:value-of select="normalize-space(mods:identifier)"/></xsl:attribute>				
				<foxml:objectProperties>
					<foxml:property NAME="info:fedora/fedora-system:def/model#state" VALUE="A"/>
					<foxml:property NAME="info:fedora/fedora-system:def/model#label"><!-- sets attribute of <foxml:digitalObject--><xsl:attribute name="VALUE"><xsl:value-of select="mods:titleInfo/mods:title"/></xsl:attribute></foxml:property>
				</foxml:objectProperties>
				
				<!-- Dublin Core Datastream -->
				<foxml:datastream ID="DC" STATE="A" CONTROL_GROUP="X">
					<foxml:datastreamVersion FORMAT_URI="http://www.openarchives.org/OAI/2.0/oai_dc/"
						ID="DC.0" MIMETYPE="text/xml" LABEL="Dublin Core Metadata">						
						<foxml:xmlContent>
							<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">								
																
								<!-- grabs DC elements from MODS_to_DC generated records in external file -->
								<xsl:variable name="item" select="$input2/srw_dc:dc[dc:identifier=current()/mods:identifier]"/>								
								<xsl:if test="$item">
									<xsl:copy-of select="$item/*"/>
								</xsl:if>															
								
							</oai_dc:dc>
						</foxml:xmlContent>
					</foxml:datastreamVersion>
				</foxml:datastream>
				
				<!-- RDF XML -->
				<foxml:datastream ID="RELS-EXT" CONTROL_GROUP="M">
					<foxml:datastreamVersion FORMAT_URI="info:fedora/fedora-system:FedoraRELSExt-1.0"
						ID="RELS-EXT.0" MIMETYPE="application/rdf+xml"
						LABEL="RDF Statements about this object">
						<foxml:xmlContent>
							<rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" 
								xmlns:fedora="info:fedora/fedora-system:def/relations-external#" 
								xmlns:myns="http://www.nsdl.org/ontologies/relationships#" 
								xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
								xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
								xmlns:wsudor="http://silo.lib.wayne.edu/fedora/objects/wayne:WSUDOR-Fedora-Relations/datastreams/RELATIONS/content">
								<rdf:Description><!-- sets attribute of <foxml:digitalObject--><xsl:attribute name="rdf:about">info:fedora/wayne:<xsl:value-of select="$collectionName"/><xsl:value-of select="normalize-space(mods:identifier)"/></xsl:attribute>                    
									<fedora:isMemberOfCollection><xsl:attribute name="rdf:resource">info:fedora/wayne:collection<xsl:value-of select="$collectionName"/></xsl:attribute></fedora:isMemberOfCollection>	
									<wsudor:hasSecurityPolicy rdf:resource="info:fedora/wayne:WSUDORSecurity-permit-apia-unrestricted"></wsudor:hasSecurityPolicy>
								</rdf:Description>
							</rdf:RDF>
						</foxml:xmlContent>
					</foxml:datastreamVersion>
				</foxml:datastream>     
				
				<!-- Images -->
				<!--ORIGINAL-->
<!--				<foxml:datastream CONTROL_GROUP="M" ID="ORIGINAL" STATE="A"> <!-\- Control Group is "M" for managed by Fedora / ID is "original" for original size -\->
					<foxml:datastreamVersion ID="ORIGINAL.0" MIMETYPE="image/tiff" LABEL="Original Image">
						<foxml:contentLocation TYPE="URL"><!-\- sets attribute of <foxml:digitalObject-\-><xsl:attribute name="REF">http://141.217.54.89/~cole/fedora_uploads/cfai/<xsl:value-of select="normalize-space(mods:identifier)"/>.tif</xsl:attribute></foxml:contentLocation>			
					</foxml:datastreamVersion>
				</foxml:datastream>-->
				
				<!--ACCESS-->
				<foxml:datastream CONTROL_GROUP="M" ID="ACCESS" STATE="A"> 
					<foxml:datastreamVersion ID="ACCESS.0" MIMETYPE="image/jpeg" LABEL="Access JPEG Image">
						<foxml:contentLocation TYPE="URL"><!-- sets attribute of <foxml:digitalObject--><xsl:attribute name="REF"><xsl:value-of select="$fileLocation"/>access/<xsl:value-of select="normalize-space(mods:identifier)"/>.jpg</xsl:attribute></foxml:contentLocation>			
					</foxml:datastreamVersion>
				</foxml:datastream> 
				
				<!--THUMBNAIL-->
				<!--Notes: Make this thumbail from the tiff files (if available) and give it dimensions of 200 x whatever scales -->
				<foxml:datastream CONTROL_GROUP="M" ID="THUMBNAIL" STATE="A"> 
					<foxml:datastreamVersion ID="THUMBNAIL.0" MIMETYPE="image/jpeg" LABEL="Thumbnail JPEG Image">
						<foxml:contentLocation TYPE="URL"><!-- sets attribute of <foxml:digitalObject--><xsl:attribute name="REF"><xsl:value-of select="$fileLocation"/>thumbs/<xsl:value-of select="normalize-space(mods:identifier)"/>.jpg</xsl:attribute></foxml:contentLocation>			
					</foxml:datastreamVersion>
				</foxml:datastream> 
				
				<!-- MODS XML -->
				<foxml:datastream ID="MODS" STATE="A" CONTROL_GROUP="M">
					<foxml:datastreamVersion ID="MODS.0" MIMETYPE="text/xml" FORMAT_URI="info:fedora/format:xml:MODS_descriptive"
						LABEL="MODS descriptive metadata">
						<foxml:xmlContent>
							<xsl:copy-of select="current-group()"/>							
						</foxml:xmlContent>
					</foxml:datastreamVersion>
				</foxml:datastream>
				
				<!--policy datasteram-->
				<foxml:datastream ID="POLICY" CONTROL_GROUP="M">
					<foxml:datastreamVersion 
						ID="POLICY.0" MIMETYPE="application/rdf+xml"
						LABEL="Policy">
						<foxml:xmlContent>
							<Policy xmlns="urn:oasis:names:tc:xacml:1.0:policy" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" PolicyId="permit-apia-unrestricted" RuleCombiningAlgId="urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable">
								<Description>Permits unrestricted API-A access.</Description>
								<Target>
									<Subjects>
										<AnySubject></AnySubject>
									</Subjects>
									<Resources>
										<AnyResource></AnyResource>
									</Resources>
									<Actions>
										<Action>
											<ActionMatch MatchId="urn:oasis:names:tc:xacml:1.0:function:string-equal">
												<AttributeValue DataType="http://www.w3.org/2001/XMLSchema#string">urn:fedora:names:fedora:2.1:action:api-a</AttributeValue>
												<ActionAttributeDesignator AttributeId="urn:fedora:names:fedora:2.1:action:api" DataType="http://www.w3.org/2001/XMLSchema#string"></ActionAttributeDesignator>
											</ActionMatch>
										</Action>
									</Actions>
								</Target>
								<Rule Effect="Permit" RuleId="1"></Rule>
							</Policy>
						</foxml:xmlContent>
					</foxml:datastreamVersion>
				</foxml:datastream>
			</foxml:digitalObject>
			<!-- WSU INGEST Template END ****************************************************************************************************************************************************** -->
			
		</xsl:result-document>
	</xsl:for-each-group>
</xsl:template>	
</xsl:stylesheet>
