################################################################################
#
# Organization Affiliations Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

require 'json'

class OrganizationAffiliationsController < ApplicationController

	before_action :connect_to_server, only: [ :index, :show ]

	#-----------------------------------------------------------------------------

	# GET /organization_affiliations

	def index
		if params[:page].present?
			@@bundle = update_page(params[:page], @@bundle)
		else
			if params[:name].present?
				reply = @@client.search(FHIR::OrganizationAffiliation, 
											search: { parameters: { classification: params[:name] } })
			else
				reply = @@client.search(FHIR::OrganizationAffiliation)
			end
			@@bundle = reply.resource
		end

    @query_params = query_params
		@organization_affiliations = @@bundle.entry.map(&:resource)
	end

	#-----------------------------------------------------------------------------

	# GET /organization_affiliations/[id]

	def show
		reply = @@client.search(FHIR::OrganizationAffiliation, 
											search: { parameters: { id: params[:id] } })
	end

  def query_params
    [
      {
        name: 'Active',
        value: 'active'
      },
      {
        name: 'Date',
        value: 'date'
      },
      {
        name: 'Email',
        value: 'email'
      },
      {
        name: 'Endpoint',
        value: 'endpoint'
      },
      {
        name: 'ID',
        value: '_id'
      },
      {
        name: 'Identifier',
        value: 'identifier'
      },
      {
        name: 'Identifier Assigner',
        value: 'identifier-assigner'
      },
      {
        name: 'Intermediary',
        value: 'via-intermediary'
      },
      {
        name: 'Location',
        value: 'location'
      },
      {
        name: 'Network',
        value: 'network'
      },
      {
        name: 'Participating Organization',
        value: 'participating-organization'
      },
      {
        name: 'Phone',
        value: 'phone'
      },
      {
        name: 'Primary Organization',
        value: 'primary-organization'
      },
      {
        name: 'Role',
        value: 'role'
      },
      {
        name: 'Service',
        value: 'service'
      },
      {
        name: 'Specialty',
        value: 'specialty'
      },
      {
        name: 'Telecom',
        value: 'telecom'
      }
    ]
  end
end
