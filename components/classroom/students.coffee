if Meteor.isServer
    Meteor.publish 'student_ids', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            _id:$in:classroom.student_ids

    Meteor.methods
        lookup_student: (username_query)->
            console.log 'searching for ', username_query
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # roles:$in:['students']
                },{limit:10}).fetch()
