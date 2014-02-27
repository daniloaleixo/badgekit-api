const util = require('util')
const db = require('../lib/db');
const makeValidator = require('../lib/make-validator')
const async = require('async')

const Criteria = db.table('criteria', {
  fields: [
    'id',
    'description',
    'badgeId',
    'required', 
    'note'
  ]
});

const Badges = db.table('badges', {
  fields: [
    'id',
    'slug',
    'name',
    'strapline',
    'earnerDescription',
    'consumerDescription',
    'issuerUrl', 
    'rubricUrl',
    'criteriaUrl',
    'timeValue',
    'timeUnits',
    'limit',
    'unique',
    'created',
    'archived',
    'imageId',
    'systemId',
    'issuerId',
    'programId'
  ],
  relationships: {
    image: {
      type: 'hasOne',
      local: 'imageId',
      foreign: { table: 'images', key: 'id' },
      optional: true
    },
    system: {
      type: 'hasOne',
      local: 'systemId',
      foreign: { table: 'systems', key: 'id' },
      optional: true,
    },
    issuer: {
      type: 'hasOne',
      local: 'issuerId',
      foreign: { table: 'issuers', key: 'id' },
      optional: true,
    },
    program: {
      type: 'hasOne',
      local: 'programId',
      foreign: { table: 'programs', key: 'id' },
      optional: true,
    },
    criteria: {
      type: 'hasMany',
      local: 'id',
      foreign: { table: 'criteria', key: 'badgeId' }
    }
  },
  methods: {
    setCriteria: setCriteria
  }
});


Badges.makeBadgeClass = function makeBadgeClass(badge) {
  // #TODO: alignment url, criteria, tags
  return {
    name: badge.name,
    description: badge.description,
    image: badge.image.toUrl(),
    criteria: badge.criteria,
    issuer: publicIssuerUrl(badge),
  }
}

function publicIssuerUrl(badge) {
  const system = badge.system
  const issuer = badge.issuer
  const program = badge.program
  if (program && program.slug)
    return util.format('/public/systems/%s/issuers/%s/programs/%s',
                      system.slug, issuer.slug, program.slug)
  if (issuer && issuer.slug)
    return util.format('/public/systems/%s/issuers',
                      system.slug, issuer.slug)
  if (badge.system && badge.system.slug)
    return util.format('/public/systems/%s', system.slug)
}

Badges.validateRow = makeValidator({
  id: optionalInt,
  slug: function (slug) {
    this.check(slug).len(1, 50);
  },
  name: function (name) {
    this.check(name).len(1, 255);
  },
  strapline: function (text) {
    this.check(text).len(0, 140);
  },
  earnerDescription: function (desc) {
    this.check(desc).len(1);
  },
  consumerDescription: function (desc) {
    this.check(desc).len(1);
  },
  timeValue: function(val) {
    if (typeof val == 'undefined' || val === null) return;
    this.check(val).isInt();
  },
  timeUnits: function(units) {
    if (typeof units == 'undefined' || units === null) return;
    this.check(units).isIn(['minutes','hours','days','weeks']);
  },
  limit: optionalInt,
  unique: function(unique) {
    this.check(unique).isIn(['0','1','true','false']);
  },
  criteriaUrl: function(url) {
    this.check(url).isUrl();
  },
  imageId: optionalInt,
  programId: optionalInt,
  issuerId: optionalInt,
  systemId: optionalInt,
});

Criteria.validateRow = makeValidator({
  id: optionalInt,
  description: function(desc) {
    this.check(desc).len(1);
  },
  required: function(required) {
    this.check(required).isIn(['0','1']);
  }
});

function optionalInt(id) {
  if (typeof id == 'undefined' || id === null) return;
  this.check(id).isInt();
}

function setCriteria(criteria, callback) {
  var criteriaIds = [];
  const badgeId = this.id;
  async.each(criteria, function(criterion, done) {
    criterion.badgeId = badgeId;
    Criteria.put(criterion, function(err, result) {
      if (err)
        return done(err);

      const rowId = result.insertId || result.row.id;
      criteriaIds.push(rowId);

      return done();
    });
  },
  function done(err) {
    if (err)
      return callback(err);

    // Now that we have added all the new criteria, we want to delete any old criteria attached to this badge
    const deleteQuery = { 
      badgeId: {
        value: badgeId,
        op: '='
      }
    };

    if (criteriaIds.length) {
      deleteQuery.id = criteriaIds.map(function(criterionId) {
        return {
          op: '!=',
          value: criterionId
        };
      });
    }

    Criteria.del(deleteQuery, function(err) {
      if (err)
        return callback(err);

      Badges.getOne({ id: badgeId }, { relationships: true }, callback);
    });
  });
}

exports = module.exports = Badges;
