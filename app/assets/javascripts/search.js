function addTaxonFilterRow() {
    // User has clicked to add another taxon row
    var lastTaxonFilterRow = $('.taxon-filter-row').last();
    // Create an element
    var el = lastTaxonFilterRow.clone(true);
    // on the clone, change the + to a -
    el.find(".add_taxon").find("i").removeClass("icon-plus-sign").addClass("icon-minus-sign");
    el.find(".add_taxon").unbind('click').bind('click', function() {
        $(this).parents(".taxon-filter-row").remove()
    });
    lastTaxonFilterRow.after(el)
}

function addTraitFilterRow() {
    // User has clicked to add another trait row
    var lastTraitFilterRow = $('.trait-filter-row').last();
    // Create an element
    var el = lastTraitFilterRow.clone(true);
    // on the clone, change the + to a -
    el.find(".add_trait").find("i").removeClass("icon-plus-sign").addClass("icon-minus-sign");
    el.find(".add_trait").unbind('click').bind('click', function() {
        $(this).parents(".trait-filter-row").remove()
    });
    lastTraitFilterRow.after(el)
}

function addButtonHandlers() {
    $('#up').bind('click', function() {
        var available = $('#available').text();
        available++;
        $('#available').text(available);
    });
    $('#down').bind('click',function() {
        var available = $('#available').text();
        available--;
        $('#available').text(available);
    });

    $('.add_taxon').bind('click', function() {
        addTaxonFilterRow();
    });
    $('.add_trait').bind('click',function() {
        addTraitFilterRow();
    });
}

function updateGenusList(familyElement, genusList) {
    // find the genus select element
    var genusElement = $(familyElement).siblings(".genus");
    // remove all options from the genus element
    genusElement.find('option').remove();
    for(var genus in genusList) {
        var obj = genusList[genus].taxon_name;
        console.log("name: " + obj.name + " id: " + obj.id);
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        genusElement.append(optionElement);
    }
}

function updateTraitNames(traitGroupElement, traitList) {
    // find the trait names select element
    var traitElement = $(traitGroupElement).siblings(".trait_name");
    // remove all options from the select
    traitElement.find('option').remove();
    for(var trait in traitList) {
        var obj = traitList[trait].chr;
        console.log("name: " + obj.name + " id: " + obj.id + " continuous: " + obj.is_continuous);
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitElement.append(optionElement);
    }
}

function updateTraitValues(traitElement, valueList) {
    // find the trait values select element
    var traitValuesElement = $(traitElement).siblings(".trait_values");
    // remove all options from the select
    traitValuesElement.find('option').remove();
    for(var traitValue in valueList) {
        var obj = valueList[traitValue];
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitValuesElement.append(optionElement);
    }
}

function familyChanged(familyElement, familyId) {
    $(familyElement).siblings(".genus").find('option').remove();
    $.ajax({
        url: "/search/list_genus.json",
        data: { family_id: familyId }
    }).done(function(data, textStatus, jqXHR) { updateGenusList(familyElement, data)});
}

function traitGroupChanged(traitGroupElement, traitGroupId) {
    $(traitGroupElement).siblings(".trait_name").find('option').remove();
    $.ajax({
        url: "/serach/list_traits.json",
        data: { trait_group_id: traitGroupId }
    }).done(function(data, textStatus, jqXHR) { updateTraitNames(traitGroupElement, data)});
}

// when a trait is changed, update the possible values
function traitChanged(traitElement, traitId) {
    $(traitElement).siblings(".trait_values").find('option').remove();
    $.ajax({
        url: "/search/list_trait_values.js",
        data: { trait_id: traitId }
    }).done(function(data, textstatus, jqXHR) { updateTraitValues(traitElement, data)});
}

function addSelectionChangeListeners() {
    // taxonomy - only observing family for now
    $('select.family').change(function() {
        familyChanged(this,this.value);
    });
    // trait
    $('select.trait_group').change(function() {
        traitGroupChanged(this,this.value);
    });
    $('select.trait_name').change(function() {
        traitChanged(this,this.value);
    });
}