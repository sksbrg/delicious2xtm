require 'nokogiri'

doc = Nokogiri::HTML(File.open("delicious.htm"))
cnt = 0
tag_cnt = 0

builder = Nokogiri::XML::Builder.new do |xtm|
	xtm.topicMap(:version => "2.0", :xmlns => "http://www.topicmaps.org/xtm/") {
		doc.xpath("//dt").each do |dt|
			a = dt.at_xpath("a")
			
			unless a.nil?
				cnt += 1
			
				xtm.topic(:id => "bookmark_" + cnt.to_s) {
					xtm.subjectLocator(:href => a["href"])
					
					xtm.instanceOf {
						xtm.topicRef(:href => "#bookmark")
					}
					
					xtm.name {
						xtm.value a.inner_html
					}
					
					xtm.occurrence {
						xtm.type_ {
							xtm.topicRef(:href => "#date_added")
						}
						xtm.resourceData(:datatype => "http://www.w3.org/2001/XMLSchema#dateTime") {
							xtm.text Time.at(a["add_date"].to_i)
						}
					}
					
					xtm.occurrence {
						xtm.type_ {
							xtm.topicRef(:href => "#url")
						}
						xtm.resourceRef(:href => a["href"])
					}
					
					unless dt.next.nil?
						xtm.occurrence {
							xtm.type_ {
								xtm.topicRef(:href => "#description")
							}
							xtm.resourceData dt.next.inner_html
						}
					end
				}
				
				a["tags"].split(',').each do |tag|
					unless tag.empty?
						tag_cnt += 1
					
						xtm.topic(:id => "tag_" + tag_cnt.to_s) {
							xtm.subjectIdentifier(:href => "http://example.com/" + tag)
							
							xtm.name {
								xtm.value tag
							}
						}
						
						xtm.association {
							xtm.type_ {
								xtm.topicRef(:href => "#tag-bookmark")
							}
							
							xtm.role {
								xtm.type_ {
									xtm.topicRef(:href => "#tag")
								}
								xtm.topicRef(:href => "#tag_" + tag_cnt.to_s)
							}
							
							xtm.role {
								xtm.type_ {
									xtm.topicRef(:href => "#bookmark")
								}
								xtm.topicRef(:href => "#bookmark_" + cnt.to_s)
							}
						}
					end
				end
			end
		end
	}
end

puts builder.to_xml
