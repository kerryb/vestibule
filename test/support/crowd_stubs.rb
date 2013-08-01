require "builder"

module CrowdStubs
  def stub_authenticate_application
    stub_request(:post, Rails.configuration.crowd_uri).
      with(&authenticate_application_request?).
      to_return(body: authenticate_application_response,
                headers: {"Content-Type" => "application/xml"})
  end

  def stub_authenticate_application_error
    stub_request(:post, Rails.configuration.crowd_uri).
      with(&authenticate_application_request?).to_raise Errno::ECONNREFUSED
  end

  def verify_authenticate_application_received
    WebMock.should have_requested(:post, Rails.configuration.crowd_uri).with &authenticate_application_request?
  end

  def authenticate_application_request?
    proc do |request|
      request_params = Hash.from_xml(request.body)["Envelope"]["Body"]["authenticateApplication"]
      request_params &&
        request_params["in0"]["name"] == Rails.configuration.crowd_application_name &&
        request_params["in0"]["credential"]["credential"] == Rails.configuration.crowd_application_password
    end
  end

  def authenticate_application_response
    Builder::XmlMarkup.new.tag!("soap:Envelope", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
                                "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                                "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do |xml|
      xml.tag! "soap:Body" do
        xml.tag! "ns1:authenticateApplicationResponse", "xmlns:ns1" => "urn:SecurityServer" do
          xml.tag! "ns1:out" do
            xml.name Rails.configuration.crowd_application_name,
              "xmlns" => "http://authentication.integration.crowd.atlassian.com"
            xml.token application_token, "xmlns" => "http://authentication.integration.crowd.atlassian.com"
          end
        end
      end
    end
  end

  def application_token
    "ACkkk00rkHwTi3IIrPHkIg00"
  end

  def stub_authenticate_principal_success username = nil, password = nil
    stub_request(:post, Rails.configuration.crowd_uri).
      with(&authenticate_principal_request?(username, password)).
      to_return(body: authenticate_principal_success_response,
                headers: {"Content-Type" => "application/xml"})
  end

  def stub_authenticate_principal_error
    stub_request(:post, Rails.configuration.crowd_uri).
      with(&authenticate_principal_request?).to_raise Errno::ECONNREFUSED
  end

  def authenticate_principal_request? username = nil, password = nil
    proc do |request|
      request_params = Hash.from_xml(request.body)["Envelope"]["Body"]["authenticatePrincipal"]
      request_params && (username.nil? ||
        request_params["in0"]["name"] == Rails.configuration.crowd_application_name &&
        request_params["in0"]["token"] == application_token &&
        request_params["in1"]["application"] == Rails.configuration.crowd_application_name &&
        (username.nil? || request_params["in1"]["name"] == username) &&
        (password.nil? || request_params["in1"]["credential"]["credential"] == password))
    end
  end

  def authenticate_principal_success_response
    Builder::XmlMarkup.new.tag!("soap:Envelope", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
                        "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do |xml|
      xml.tag! "soap:Body" do
        xml.tag! "ns1:authenticatePrincipalResponse", "xmlns:ns1" => "urn:SecurityServer" do
          xml.tag! "ns1:out", "mj7IBmGAxnVC8JLBPxoYgQ00"
        end
      end
    end
  end

  def stub_authenticate_principal_fail username, password
    stub_request(:post, Rails.configuration.crowd_uri).
      with(&authenticate_principal_request?(username, password)).
      to_return(body: authenticate_principal_fail_response,
                headers: {"Content-Type" => "application/xml"}, status: 500)
  end

  def authenticate_principal_fail_response
    Builder::XmlMarkup.new.tag!("soap:Envelope", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
                                "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                                "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do |xml|
      xml.tag! "soap:Body" do
        xml.tag! "soap:Fault" do
          xml.faultcode "soap:Server"
          xml.faultstring "User 123456789 not found with supplied password"
          xml.detail do
            xml.tag! "InvalidAuthenticationException", "xmlns" => "urn:SecurityServer"
          end
        end
      end
    end
  end

  def stub_find_principal_by_name username, first_name, last_name, email = "#{username}@bt.com", ouc = "ABC1"
    stub_request(:post, Rails.configuration.crowd_uri).with(&find_principal_by_name_request?(username)).
      to_return(body: find_principal_by_name_response(username, first_name, last_name, email, ouc),
                headers: {"Content-Type" => "application/xml"})
  end

  def find_principal_by_name_request? username
    proc do |request|
      request_params = Hash.from_xml(request.body)["Envelope"]["Body"]["findPrincipalByName"]
      request_params &&
        request_params["in0"]["name"] == Rails.configuration.crowd_application_name &&
        request_params["in0"]["token"] == application_token &&
        (username.nil? || request_params["in1"] == username)
    end
  end

  def find_principal_by_name_response username, first_name, last_name, email, ouc
    Builder::XmlMarkup.new.tag!("soap:Envelope", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
                        "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do |xml|
      xml.tag! "soap:Body" do
        xml.tag! "ns1:findPrincipalByNameResponse", "xmlns:ns1" => "urn:SecurityServer" do
          xml.tag! "ns1:out" do
            xml.tag! "ID", "-1", "xmlns" => "http://soap.integration.crowd.atlassian.com"
            xml.active "true", "xmlns" => "http://soap.integration.crowd.atlassian.com"
            xml.attributes "xmlns" => "http://soap.integration.crowd.atlassian.com" do
              {"mail" => email,
                "sn" => last_name,
                "manager" => "812345678",
                "department" => "DMK",
                "dn" => "cn=#{username},ou=people,ou=BTplc,o=bt",
                "givenName" => first_name,
                "displayName" => "#{first_name} #{last_name} (#{ouc})",
                "type" => "person",
                "companyCode" => "D00"
              }.each do |key, value|
                xml.tag! "SOAPAttribute" do
                  xml.name key
                  xml.values do
                    xml.tag! "ns1:string", value
                  end
                end
              end
            end
            xml.description "xmlns" => "http://soap.integration.crowd.atlassian.com", "xsi:nil" => "true"
            xml.directoryID "32770", "xmlns" => "http://soap.integration.crowd.atlassian.com"
            xml.name username, "xmlns" => "http://soap.integration.crowd.atlassian.com"
          end
        end
      end
    end
  end

  def stub_find_principal_by_name_fail username
    stub_request(:post, Rails.configuration.crowd_uri).with do |request|
      request_params = Hash.from_xml(request.body)["Envelope"]["Body"]["findPrincipalByName"]
      request_params && request_params["in1"] == username
      request.body =~ /findPrincipalByName/
    end.to_return(body: find_principal_by_name_fail_response(username),
                  headers: {"Content-Type" => "application/xml"})
  end

  def stub_find_principal_by_name_functional_account username, display_name
    stub_request(:post, Rails.configuration.crowd_uri).with do |request|
      request_params = Hash.from_xml(request.body)["Envelope"]["Body"]["findPrincipalByName"]
      request_params && request_params["in1"] == username
      request.body =~ /findPrincipalByName/
    end.to_return(body: find_principal_by_name_functional_account_response(username, display_name),
                  headers: {"Content-Type" => "application/xml"})
  end

  def find_principal_by_name_functional_account_response username, display_name
    Builder::XmlMarkup.new.tag!("soap:Envelope", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
                        "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do |xml|
      xml.tag! "soap:Body" do
        xml.tag! "ns1:findPrincipalByNameResponse", "xmlns:ns1" => "urn:SecurityServer" do
          xml.tag! "ns1:out" do
            xml.tag! "ID", "-1", "xmlns" => "http://soap.integration.crowd.atlassian.com"
            xml.active "true", "xmlns" => "http://soap.integration.crowd.atlassian.com"
            xml.attributes "xmlns" => "http://soap.integration.crowd.atlassian.com" do
              {"sn" => username,
                "displayName" => "#{display_name}"
              }.each do |key, value|
                xml.tag! "SOAPAttribute" do
                  xml.name key
                  xml.values do
                    xml.tag! "ns1:string", value
                  end
                end
              end
            end
            xml.description "xmlns" => "http://soap.integration.crowd.atlassian.com", "xsi:nil" => "true"
            xml.directoryID "32770", "xmlns" => "http://soap.integration.crowd.atlassian.com"
            xml.name username, "xmlns" => "http://soap.integration.crowd.atlassian.com"
          end
        end
      end
    end
  end
  def stub_find_principal_by_name_empty_response username
    stub_request(:post, Rails.configuration.crowd_uri).with do |request|
      request_params = Hash.from_xml(request.body)["Envelope"]["Body"]["findPrincipalByName"]
      request_params && request_params["in1"] == username
      request.body =~ /findPrincipalByName/
    end.to_return(body: "<xml></xml>",
                  headers: {"Content-Type" => "application/xml"})
  end

  def find_principal_by_name_fail_response username
    Builder::XmlMarkup.new.tag!("soap:Envelope", "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
                                "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                                "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do |xml|
      xml.tag! "soap:Body" do
        xml.tag! "soap:Fault" do
          xml.faultcode "soap:Server"
          xml.faultstring "Principal #{username} not found"
          xml.detail do
            xml.tag! "InvalidAuthenticationException", "xmlns" => "urn:SecurityServer"
          end
        end
      end
    end
  end
end
