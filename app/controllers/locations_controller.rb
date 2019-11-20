# frozen_string_literal: true

################################################################################
#
# Locations Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

require 'json'

class LocationsController < ApplicationController
  before_action :connect_to_server, only: [:index, :show]

  #-----------------------------------------------------------------------------

  # GET /locations

    def index
      if params[:page].present?
        update_page(params[:page])
      else
        if params[:query_string].present?
          parameters = query_hash_from_string(params[:query_string])
          initparams = parameters 
          modifiedparams = zip_plus_radius_to_near(initparams) if parameters 
    #     reply = @client.search(FHIR::Location,
    #                         search: { parameters: parameters }) 
          reply = @client.search(FHIR::Location,
                                  search: {
                                    parameters: modifiedparams.merge(
                                      _profile: 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Location'
                                    )
                                  }
                                )         
        else
    #      reply = @client.search(FHIR::Location)
      reply = @client.search(FHIR::Location,
      search: {
        parameters: {
          _profile: 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Location'
        }
      }
    )

        end
        @bundle = reply.resource
      end

      update_bundle_links

      @query_params = query_params
      @locations = @bundle.entry.map(&:resource)
    end

  #-----------------------------------------------------------------------------

  # GET /locations/[id]

  def show
    reply = @client.search(FHIR::Location,
                           search: { parameters: { _id: params[:id] } })
    bundle = reply.resource
    fhir_location = bundle.entry.map(&:resource).first

    @location = Location.new(fhir_location) unless fhir_location.nil?
  end

  def query_params
    [
      {
        name: 'ID',
        value: '_id'
      },
      {
        name: 'Accessibility',
        value: 'accessibility'
      },
      {
        name: 'Address',
        value: 'address'
      },
      {
        name: 'Available Days',
        value: 'available-days'
      },
      {
        name: 'Available End Time',
        value: 'available-endtime'
      },
      {
        name: 'Available Start Time',
        value: 'available-start-time'
      },
      {
        name: 'City',
        value: 'address-city'
      },
      {
        name: 'Contains',
        value: 'contains'
      },
      {
        name: 'Country',
        value: 'address-country'
      },
      {
        name: 'endpoint',
        value: 'Endpoint'
      },
      {
        name: 'Identifier',
        value: 'identifier'
      },
      {
        name: 'Intermediary',
        value: 'via-intermediary'
      },
      {
        name: 'Identifier Assigner',
        value: 'identifier-assigner'
      },
      {
        name: 'New Patient Network',
        value: 'new-patient-network'
      },
      {
        name: 'Radius (in miles from center of zipcode)',
        value: 'radius'
      },
      {
        name: 'New Patient',
        value: 'new-patient'
      },
      {
        name: 'Operational Status',
        value: 'operational-status'
      },
      {
        name: 'Organization',
        value: 'organization'
      },
      {
        name: 'Part of',
        value: 'partof'
      },
      {
        name: 'Postal Code',
        value: 'address-postalcode'
      },
      {
        name: 'State',
        value: 'address-state'
      },
      {
        name: 'Status',
        value: 'status'
      },
      {
        name: 'Telecom Available Days',
        value: 'telecom-available-days'
      },
      {
        name: 'Telecom Available End Time',
        value: 'telecom-available-endtime'
      },
      {
        name: 'Telecom Available Start Time',
        value: 'telecom-available-start-time'
      },
      {
        name: 'Type',
        value: 'type'
      },
      {
        name: 'Use',
        value: 'address-use'
      }
    ]
  end

# This version is different than the one in the other two controllers, since it uses "address-postalcode" instead of "zip" and it uses "zip" and not :zip
  def zip_plus_radius_to_near(params)
    #  Convert zipcode + radius to  lat/long+radius in lat|long|radius|units format
    if params["address-postalcode"].present?   # delete zip and radius params and replace with near
      radius = 25
      zip = params["address-postalcode"]
      params.delete("address-postalcode")
      if params["radius"].present?
        radius = params["radius"]
        params.delete("radius")
      end
      # get coordinate
      coords = get_zip_coords(zip)
      near = "#{coords["lat"]}|#{coords["lng"]}|#{radius}|mi"
      params[:near]=near 
    end
    params
  end

    # Geolocation from MapQuest... 
    # <<< probably should put Key in CONSTANT and put it somewhere more rational than inline >>>>
def get_zip_coords(zipcode)
  response = HTTParty.get(
    'http://open.mapquestapi.com/geocoding/v1/address',
    query: {
      key: 'A4F1XOyCcaGmSpgy2bLfQVD5MdJezF0S',
      postalCode: zipcode,
      country: 'USA',
      thumbMaps: false
    }
  )

  # coords = response.deep_symbolize_keys&.dig(:results)&.first&.dig(:locations).first&.dig(:latLng)
  coords = response["results"].first["locations"].first["latLng"]

end

end
