if Meteor.isClient
    Template.company_section_cloud.onCreated ->
        @autorun -> Meteor.subscribe('company_section_tags', selected_company_section_tags.array())
        @autorun -> Meteor.subscribe('company_section_docs', selected_company_section_tags.array())
    Template.company_section_cloud.helpers
        all_company_section_tags: ->
            company_section_count = Docs.find(model:'company_section').count()
            if 0 < company_section_count < 3 then company_section_tags.find { count: $lt: company_section_count } else company_section_tags.find({},{limit:10})
        selected_company_section_tags: -> selected_company_section_tags.array()
    Template.company_section_cloud.events
        'click .select_company_section_tag': -> selected_company_section_tags.push @name
        'click .unselect_company_section_tag': -> selected_company_section_tags.remove @valueOf()
        'click #clear_tags': -> selected_company_section_tags.clear()



if Meteor.isServer
    Meteor.publish 'company_section_tags', (selected_company_section_tags)->
        self = @
        match = {}

        if selected_company_section_tags.length > 0 then match.tags = $all: selected_company_section_tags
        match.model = 'company_section'
        console.log match
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_company_section_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'company_section_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'company_section_docs', (selected_company_section_tags)->
        # company = Meteor.companys.findOne @companyId
        console.log selected_company_section_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_company_section_tags.length > 0 then match.tags = $all: selected_company_section_tags
        match.model = 'company_section'
        Docs.find match, sort:_timestamp:-1
