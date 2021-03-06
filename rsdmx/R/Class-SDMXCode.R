#' @name SDMXCode
#' @docType class
#' @aliases SDMXCode-class
#' 
#' @title Class "SDMXCode"
#' @description A basic class to handle a SDMX Code
#' 
#' @slot id Object of class "character" giving the ID of the code (required). 
#'        In SDMX 2.0 documents, this slot will handle the 'value' attribute
#' @slot urn Object of class "character" giving the code urn
#' @slot parentCode Object of class "character" giving the parent code
#' @slot label Object of class "list" giving the code label (by language). In SDMX 2.0, 
#'       it takes the code 'Description' element vs. 'Name' element in SDMX 2.1
#'
#' @section Warning:
#' This class is not useful in itself, but all SDMX non-abstract classes will 
#' encapsulate it as slot, when parsing an SDMX-ML document (Codelists, or 
#' DataStructureDefinition)
#' 
#' @author Emmanuel Blondel, \email{emmanuel.blondel1@@gmail.com}
#' 
setClass("SDMXCode",
         representation(
           #attributes
           id = "character", #required (equivalent to "value" in SDMX 2.0)
           urn = "character", #optional
           parentCode = "character", #optional
           
           #elements
           label = "list" #optional - generic slot that will handle the code label
                          #using the 'Name' (SDMX 2.1) or 'Description' (SDMX 2.0)
         ),
         prototype = list(
           #attributes
           id = "CODE_ID",
           urn = as.character(NA),
           parentCode = as.character(NA),
           
           #elements
           label = list(
             en = "code label",
             fr = "label du code"
           )
         ),
         validity = function(object){
           
           #eventual validation rules
           if(.rsdmx.options$validate){
            if(is.na(object@id)) return(FALSE)
            if(length(object@label) == 0) return(FALSE)
           }
           
           return(TRUE);
         }
)