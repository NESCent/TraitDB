var uniqueRowId = 1;

function addTaxonFilterRow() {
    // User has clicked to add another taxon row
    var lastTaxonFilterRow = $('.taxon-filter-row').last();
    // Create an element
    var el = lastTaxonFilterRow.clone(true);
    // update the ids
    uniqueRowId++;
    var htgId = "htg_" + uniqueRowId;
    var orderId = "order_" + uniqueRowId;
    var familyId = "family_" + uniqueRowId;
    var genusId = "genus_" + uniqueRowId;
    el.find('select.htg').attr('id',htgId).attr('name','htg[' + uniqueRowId + ']');
    el.find('select.order').attr('id',orderId).attr('name','order[' + uniqueRowId + ']');
    el.find('select.family').attr('id',familyId).attr('name','family[' + uniqueRowId + ']');
    el.find('select.genus').attr('id',genusId).attr('name','genus[' + uniqueRowId + ']');
    el.hide();
    lastTaxonFilterRow.after(el);
    el.show('fast');
}

function addTraitFilterRow() {
    // User has clicked to add another trait row
    var lastTraitFilterRow = $('.trait-filter-row').last();
    // Create an element
    var el = lastTraitFilterRow.clone(true);
    // update the ids
    uniqueRowId++;

    var traitTypeId = "trait_type_" + uniqueRowId;
    var categoricalTraitNameId = "categorical_trait_name_" + uniqueRowId;
    var categoricalTraitValuesId = "categorical_trait_values_" + uniqueRowId;
    var continuousTraitNameId = "continuous_trait_name_" + uniqueRowId;
    var continuousTraitValuePredicatesId = "continuous_trait_value_predicates_" + uniqueRowId;
    var continuousTraitEntriesId = "continous_trait_entries_" + uniqueRowId;

    el.find('select.trait_type').attr('id',traitTypeId).attr('name','trait_type[' + uniqueRowId + ']');
    el.find('select.categorical_trait_name').attr('id',categoricalTraitNameId).attr('name','categorical_trait_name[' + uniqueRowId + ']');
    el.find('select.categorical_trait_values').attr('id',categoricalTraitValuesId).attr('name','categorical_trait_values[' + uniqueRowId + ']');
    el.find('select.continuous_trait_name').attr('id',continuousTraitNameId).attr('name','continuous_trait_name[' + uniqueRowId + ']');
    el.find('select.continuous_trait_value_predicates').attr('id',continuousTraitValuePredicatesId).attr('name','continuous_trait_value_predicates[' + uniqueRowId + ']');
    el.find('input.continuous_trait_entries').attr('id',continuousTraitEntriesId).attr('name','continuous_trait_entries[' + uniqueRowId + ']');
    el.hide();
    lastTraitFilterRow.after(el);
    el.show('fast');
}

function addButtonHandlers() {
    $('.add_taxon').bind('click', function() {
        addTaxonFilterRow();
    });
    $('.remove_taxon').bind('click', function() {
        if ($(".taxon-filter-row").length > 1) {
            // Don't remove the only row
            $(this).parents(".taxon-filter-row").hide('fast', function () {
                $(this).remove();
            });

        }
    });
    $('.add_trait').bind('click',function() {
        addTraitFilterRow();
    });
    $('.remove_trait').bind('click', function() {
        if ($(".trait-filter-row").length > 1) {
            // Don't remove the only row
            $(this).parents(".trait-filter-row").hide('fast', function () {
                $(this).remove();
            });
        }
    });
}

function updateOrderList(higherGroupElement, orderList) {
    var orderElement = $(higherGroupElement).siblings(".order");
    // remove all options from the element
    orderElement.find('option').remove();
    orderElement.append($('<option value>-- All --</option>'));
    for(var order in orderList) {
        var obj = orderList[order];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        orderElement.append(optionElement);
    }
    // Also clear the lower levels
    $(orderElement).siblings(".family").find('option').remove();
    $(orderElement).siblings(".genus").find('option').remove();
}

function updateFamilyList(orderElement, familyList) {
    var familyElement = $(orderElement).siblings(".family");
    // remove all options from the element
    familyElement.find('option').remove();
    familyElement.append($('<option value>-- All --</option>'));

    for(var family in familyList) {
        var obj = familyList[family];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        familyElement.append(optionElement);
    }
    $(familyElement).siblings(".genus").find('option').remove();
}

function updateGenusList(familyElement, genusList) {
    // find the genus select element
    var genusElement = $(familyElement).siblings(".genus");
    // remove all options from the genus element
    genusElement.find('option').remove();
    genusElement.append($('<option value>-- All --</option>'));
    for(var genus in genusList) {
        var obj = genusList[genus];
        console.log("name: " + obj.name + " id: " + obj.id);
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        genusElement.append(optionElement);
    }
}

function updateCategoricalTraitNames(traitTypeElement, traitList) {
    // find the trait names select element
    var traitElement = $(traitTypeElement).siblings(".categorical_trait_name");
    // remove all options from the select
    traitElement.find('option').remove();
    traitElement.append($('<option value>-- Select --</option>'));
    for(var trait in traitList) {
        var obj = traitList[trait];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitElement.append(optionElement);
    }
}

function updateContinuousTraitNames(traitTypeElement, traitList) {
    // find the trait names select element
    var traitElement = $(traitTypeElement).siblings(".continuous_trait_name");
    // remove all options from the select
    traitElement.find('option').remove();
    traitElement.append($('<option value>-- Select --</option>'));
    for(var trait in traitList) {
        var obj = traitList[trait];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitElement.append(optionElement);
    }
}

function updateContinuousTraitValuePredicates(traitElement) {
    var traitValuesElement = $(traitElement).siblings(".continuous_trait_value_predicates");
    traitValuesElement.find('option').remove();
    traitValuesElement.append($('<option value>-- All Values --</option>'));
    traitValuesElement.append($('<option value="eq">= (Equals)</option>'));
    traitValuesElement.append($('<option value="ne">!= (Does not equal)</option>'));
    traitValuesElement.append($('<option value="gt">&gt; (Is greater than)</option>'));
    traitValuesElement.append($('<option value="lt">&lt; (Is less than)</option>'));
    updateContinuousTraitEntries(traitValuesElement);
}

function updateContinuousTraitEntries(traitValuesElement) {
    if (traitValuesElement.value == 'in') {
        // show the second field
        // would be good to resize too
        $(traitValuesElement).siblings('.continuous_trait_entries').children('.field2').show();
    } else {
        // hide the second field
        $(traitValuesElement).siblings('.continuous_trait_entries').children('.field2').hide();
    }
}

function updateCategoricalTraitValues(traitElement, valueList) {
    // find the trait values select element
    var traitValuesElement = $(traitElement).siblings(".categorical_trait_values");
    // remove all options from the select
    traitValuesElement.find('option').remove();
    traitValuesElement.append($('<option value>-- Select --</option>'));
    for(var traitValue in valueList) {
        var obj = valueList[traitValue];
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitValuesElement.append(optionElement);
    }
}

function higherGroupChanged(higherGroupElement, higherGroupId) {
    $(higherGroupElement).siblings(".order").find('option').remove();
    $.ajax({
        url: "/search/list_order.json",
        data: { htg_id: higherGroupId}
    }).done(function(data, textStatus, jqXHR) { updateOrderList(higherGroupElement, data); });
}

function orderChanged(orderElement, orderId) {
    $(orderElement).siblings(".family").find('option').remove();
    $.ajax({
        url: "/search/list_family.json",
        data: { order_id: orderId}
    }).done(function(data, textStatus, jqXHR) { updateFamilyList(orderElement, data); });
}

function familyChanged(familyElement, familyId) {
    $(familyElement).siblings(".genus").find('option').remove();
    $.ajax({
        url: "/search/list_genus.json",
        data: { family_id: familyId }
    }).done(function(data, textStatus, jqXHR) { updateGenusList(familyElement, data); });
}

// need an update trait types
function traitTypeChanged(traitTypeElement, traitTypeId) {
    if(traitTypeElement.value == 'continuous') {
        $(traitTypeElement).siblings(".continuous_trait_name").find('option').remove();
        $(traitTypeElement).siblings(".continuous_trait_name, .continuous_trait_value_predicates, .continuous_trait_entries").show('fast');
        $(traitTypeElement).siblings(".categorical_trait_name, .categorical_trait_values").hide('fast');
        $.ajax({
            url: "/search/list_continuous_trait_names.json"
        }).done(function(data, textstatus, jqXHR) { updateContinuousTraitNames(traitTypeElement, data); });
    } else {
        $(traitTypeElement).siblings(".categorical_trait_name").find('option').remove();
        $(traitTypeElement).siblings(".continuous_trait_name, .continuous_trait_value_predicates, .continuous_trait_entries").hide('fast');
        $(traitTypeElement).siblings(".categorical_trait_name, .categorical_trait_values").show('fast');
        $.ajax({
            url: "/search/list_categorical_trait_names.json"
        }).done(function(data, textstatus, jqXHR) { updateCategoricalTraitNames(traitTypeElement, data); });
    }

}

function categoricalTraitNameChanged(categoricalTraitNameElement, traitId) {
    $(categoricalTraitNameElement).siblings(".categorical_trait_values").find('option').remove();
    $.ajax({
        url: "/search/list_categorical_trait_values.js",
        data: { trait_id: traitId }
    }).done(function(data, textstatus, jqXHR) { updateCategoricalTraitValues(categoricalTraitNameElement, data); });
}

function continuousTraitNameChanged(continuousTraitNameElement, traitId) {
    updateContinuousTraitValuePredicates(continuousTraitNameElement);
}

function continuousTraitValuePredicateChanged(continuousTraitValuePredicateElement, predicateId) {

}

function continuousTraitEntryChanged(continuousTraitEntryElement, entryId) {

}

function addSelectionChangeListeners() {
    // taxonomy
    $('select.htg').change(function() {
        higherGroupChanged(this,this.value);
    });
    $('select.order').change(function() {
        orderChanged(this,this.value);
    });
    $('select.family').change(function() {
        familyChanged(this,this.value);
    });

    // trait
    $('select.trait_type').change(function() {
        traitTypeChanged(this,this.value);
    });
    $('select.categorical_trait_name').change(function() {
        categoricalTraitNameChanged(this,this.value);
    });
    $('select.continuous_trait_name').change(function() {
        continuousTraitNameChanged(this,this.value);
    });
    $('select.continuous_trait_value_predicates').change(function() {
        continuousTraitValuePredicateChanged(this,this.value);
    });
    $('input.continuous_trait_entries').change(function() {
        continuousTraitEntryChanged(this,this.value);
    });

}

function hideContinuousFields() {
    $('select.continuous_trait_name').hide();
    $('select.continuous_trait_value_predicates').hide();
    $('input.continuous_trait_entries').hide();
}
