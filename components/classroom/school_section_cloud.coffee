if Meteor.isClient
    Template.school_section_cloud.onCreated ->
        @autorun -> Meteor.subscribe('school_section_tags', selected_school_section_tags.array())
        @autorun -> Meteor.subscribe('school_section_docs', selected_school_section_tags.array())
    Template.school_section_cloud.helpers
        all_school_section_tags: ->
            school_section_count = Docs.find(model:'school_section').count()
            if 0 < school_section_count < 3 then school_section_tags.find { count: $lt: school_section_count } else school_section_tags.find({},{limit:10})
        selected_school_section_tags: -> selected_school_section_tags.array()
    Template.school_section_cloud.events
        'click .select_school_section_tag': -> selected_school_section_tags.push @name
        'click .unselect_school_section_tag': -> selected_school_section_tags.remove @valueOf()
        'click #clear_tags': -> selected_school_section_tags.clear()



if Meteor.isServer
    Meteor.publish 'school_section_tags', (selected_school_section_tags)->
        self = @
        match = {}

        if selected_school_section_tags.length > 0 then match.tags = $all: selected_school_section_tags
        match.model = 'school_section'
        console.log match
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $classroom: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_school_section_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'school_section_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'school_section_docs', (selected_school_section_tags)->
        # school = Meteor.schools.findOne @schoolId
        console.log selected_school_section_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_school_section_tags.length > 0 then match.tags = $all: selected_school_section_tags
        match.model = 'school_section'
        Docs.find match, sort:_timestamp:-1
