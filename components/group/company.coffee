if Meteor.isClient
    Router.route '/companys', ->
        @render 'companys'
    Router.route '/company/:doc_id/', (->
        @layout 'company_view_layout'
        @render 'company_dashboard'
        ), name:'company_view'
    Router.route '/company/:doc_id/dashboard', (->
        @layout 'company_view_layout'
        @render 'company_dashboard'
        ), name:'company_dashboard'
    Router.route '/company/:doc_id/reports', (->
        @layout 'company_view_layout'
        @render 'company_reports'
        ), name:'company_reports'
    Router.route '/company/:doc_id/stats', (->
        @layout 'company_view_layout'
        @render 'company_stats'
        ), name:'company_stats'
    Router.route '/company/:doc_id/debits', (->
        @layout 'company_view_layout'
        @render 'company_debits'
        ), name:'company_debits'
    Router.route '/company/:doc_id/credits', (->
        @layout 'company_view_layout'
        @render 'company_credits'
        ), name:'company_credits'
    Router.route '/company/:doc_id/members', (->
        @layout 'company_view_layout'
        @render 'company_members'
        ), name:'company_members'
    Router.route '/company/:doc_id/feed', (->
        @layout 'company_view_layout'
        @render 'company_feed'
        ), name:'company_feed'
    Router.route '/company/:doc_id/loans', (->
        @layout 'company_view_layout'
        @render 'company_loans'
        ), name:'company_loans'
    Router.route '/company/:doc_id/leaderboard', (->
        @layout 'company_view_layout'
        @render 'company_leaderboard'
        ), name:'company_leaderboard'
    Router.route '/company/:doc_id/grades', (->
        @layout 'company_view_layout'
        @render 'company_grades'
        ), name:'company_grades'
    Router.route '/company/:doc_id/stock', (->
        @layout 'company_view_layout'
        @render 'company_stock'
        ), name:'company_stock'
    Router.route '/company/:doc_id/sponsor', (->
        @layout 'company_view_layout'
        @render 'company_sponsor'
        ), name:'company_sponsor'
    Router.route '/company/:doc_id/shop', (->
        @layout 'company_view_layout'
        @render 'company_shop'
        ), name:'company_shop'
    Router.route '/company/:doc_id/jobs', (->
        @layout 'company_view_layout'
        @render 'company_jobs'
        ), name:'company_jobs'
    Router.route '/company/:doc_id/services', (->
        @layout 'company_view_layout'
        @render 'company_services'
        ), name:'company_services'
    Router.route '/company/:doc_id/info', (->
        @layout 'company_view_layout'
        @render 'company_info'
        ), name:'company_info'



if Meteor.isClient
    Template.companys.onRendered ->

        # Session.setDefault 'view_mode', 'cards'
    Template.companys.helpers

        # viewing_cards: -> Session.equals 'view_mode', 'cards'
        # viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.companys.events
        # 'click .set_card_view': ->
        #     Session.set 'view_mode', 'cards'
        # 'click .set_segment_view': ->
        #     Session.set 'view_mode', 'segments'


    Template.company_card.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'company_stats'



    Template.company_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'company_members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
    Template.company_dashboard.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700
    Template.company_dashboard.helpers
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                company_id: Router.current().params.doc_id

    Template.company_members.onCreated ->
        @autorun => Meteor.subscribe 'company_members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        @autorun => Meteor.subscribe 'model_docs', 'company_event'
    Template.company_members.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion(
                selector: {
                    trigger: '.title .header'
                }
            )
        , 1000

    Template.company_members.helpers
        company_members: ->
            Meteor.users.find()
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                company_id: Router.current().params.doc_id
        company_debit_types: ->
            Docs.find
                model:'debit_type'
                # weekly:$ne:true
                company_id: Router.current().params.doc_id
        member_events: ->
            Docs.find
                model:'company_event'
                user_id: @_id

    Template.company_members.events
        'click .add_bonus': (e,t)->
            # alert 'hi'
            # console.log @
            company = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.title').transition('bounce', 1000)
            # console.log @
            $('body').toast({
                message: 'bonus given'
                class:'success'
                showProgress: 'bottom'
            })

            Meteor.users.update @_id,
                $inc:credit:company.bonus_amount
            Docs.insert
                model:'company_event'
                event_type:'credit'
                amount: company.bonus_amount
                text:"was credited #{company.bonus_amount}"
                user_id: @_id
                company_id: Router.current().params.doc_id


        'click .add_fine': (e,t)->
            company = Docs.findOne Router.current().params.doc_id

            $(e.currentTarget).closest('.title').transition('shake', 1000)
            $('body').toast({
                message: 'fine given'
                class:'error'
                showProgress: 'bottom'
            })

            Meteor.users.update @_id,
                $inc:credit:-company.fines_amount
            Docs.insert
                model:'company_event'
                event_type:'debit'
                amount: company.fines_amount
                text:"was fined #{company.fines_amount}"
                user_id: @_id
                company_id: Router.current().params.doc_id



        'change .date_select': ->
            console.log $('.date_select').val()




    Template.company_members.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000

    Template.company_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'company_members', Router.current().params.doc_id
    Template.company_reports.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700
    Template.company_reports.helpers
        company_members: ->
            Meteor.users.find()
    Template.company_reports.events
        'change .date_select': ->
            console.log $('.date_select').val()










    Template.company_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'
        # @autorun => Meteor.subscribe 'model_docs', 'company_section'

    Template.company_view_layout.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        # Meteor.setTimeout ->
        #     $('.tabular.menu .item').tab()
        # , 1000

    Template.company_view_layout.helpers
        company_sections: ->
            Docs.find {
                model:'company_section'
            }, title:1
        route_slug: -> "company_#{@slug}"

        features: ->
            Docs.find
                model:'feature'
        feature_view_template: ->
            "#{@title}_view_template"

        selected_features: ->
            company = Docs.findOne Router.current().params.doc_id
            Docs.find(
                _id: $in: company.feature_ids
                model:'feature'
            ).fetch()




    Template.company_feed.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'company_event'
    Template.company_feed.helpers
        company_events: ->
            Docs.find {
                model:'company_event'
                company_id:Router.current().params.doc_id
            }, sort: _timestamp:-1

    Template.company_feed.events
        'click .remove': (e,t)->
            if confirm  "undo #{@event_type}?"
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 500
                if @event_type is 'credit'
                    Meteor.users.update @user_id,
                        $inc:credit:-@amount
                else if @event_type is 'debit'
                    Meteor.users.update @user_id,
                        $inc:credit:@amount







    Template.company_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'company_stats'


    Template.company_stats.helpers
        gsd: ->
            Docs.findOne
                model:'company_stats'
                company_id:Router.current().params.doc_id
    Template.company_stats.events
        'click .refresh_company_stats': ->
            Meteor.call 'refresh_company_stats', @_id




if Meteor.isServer
    Meteor.publish 'company_members', (company_id)->
        company = Docs.findOne company_id
        Meteor.users.find
            username: $in: company.members

    Meteor.publish 'companys', (product_id)->
        Docs.find
            model:'company'
            product_id:product_id

    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'reservation_slot', (moment_ob)->
        companys_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            companys.return.push date_string
        companys_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_company_stats: (company_id)->
            company = Docs.findOne company_id
            # console.log company
            company_stats_doc = Docs.findOne
                model:'company_stats'
                company_id: company_id

            unless company_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'company_stats'
                    company_id: company_id
                company_stats_doc = Docs.findOne new_stats_doc_id

            member_count = company.members.length

            debits = Docs.find({
                model:'company_event'
                event_type:'debit'
                company_id:company_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'company_event'
                event_type:'credit'
                company_id:company_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            company_balance = total_credit_amount-total_debit_amount

            average_credit_per_member = total_credit_amount/member_count
            average_debit_per_member = total_debit_amount/member_count


            Docs.update company_stats_doc._id,
                $set:
                    member_count: member_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    debit_count: debit_count
                    credit_count: credit_count
                    company_balance: company_balance
                    average_credit_per_member: average_credit_per_member.toFixed(2)
                    average_debit_per_member: average_debit_per_member.toFixed(2)

            # .ui.small.header total earnings
            # .ui.small.header company ranking #reservations
            # .ui.small.header company ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg company time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
